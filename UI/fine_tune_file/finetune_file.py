#code changed
import os
import torch
from datasets import load_dataset, Dataset
import pandas as pd
import transformers
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig
from trl import SFTTrainer
import transformers
# from peft import AutoPeftModelForCausalLM
from transformers import GenerationConfig
from pynvml import *
import glob
class custom_model_trainer:
    lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout=5e-6,3,4,4,4,16,32,.05 # setup the parameter accoring to your model.
    def formatted_text(x,tokenizer):
            # change this templete according to your model
            #Example: 
            temp = [
            {"role": "user", "content": """You are a helpful chatbot, help users by answering their queries.
            Question: """ + x["question"]},
            {"role": "assistant", "content": x["answer"]}
            ]
            return tokenizer.apply_chat_template(temp, add_generation_prompt=False, tokenize=False)
    def custom_model_finetune(self):
        base_model = 'mistralai/Mistral-7B-Instruct-v0.2' # Write the base model repo name from huggingface
        lora_output = 'mymodel_lora' # Write the folder name for saving lora output
        full_output = 'mymodel_full' # Write the folder name for saving full model output
        DEVICE = 'cuda'
        tokenizer = AutoTokenizer.from_pretrained(base_model)
        tokenizer.padding_side = 'right'
        ### read csv with Prompt, Answer pair 
        data_location = r"data/finetune_data.xlsx" ## replace here
        data_df=pd.read_excel( data_location )
        ### set formatting
        data_df["text"] = data_df[["question", "answer"]].apply(lambda x: self.formatted_text(x,tokenizer), axis=1) ## replace Prompt and Answer if collected dataset has different column names
        print(data_df.iloc[0])
        dataset = Dataset.from_pandas(data_df)


        # set quantization config
        if self.quantization == '8':
            bnb_config = BitsAndBytesConfig(  
                load_in_8bit= True,
            )
        elif self.quantization == '4':
            bnb_config = BitsAndBytesConfig(
                load_in_4bit= True,
                bnb_4bit_use_double_quant=True,
                bnb_4bit_quant_type="nf4",  
                bnb_4bit_compute_dtype=torch.bfloat16
            )
        model = AutoModelForCausalLM.from_pretrained(
                base_model,
                quantization_config=bnb_config,
                torch_dtype=torch.bfloat16,
                device_map="auto",
                trust_remote_code=True,
        )
        model.config.use_cache = False # silence the warnings
        model.config.pretraining_tp = 1
        model.gradient_checkpointing_enable()

        tokenizer = AutoTokenizer.from_pretrained(base_model, trust_remote_code=True)
        tokenizer.padding_side = 'right'
        tokenizer.pad_token = tokenizer.eos_token
        tokenizer.add_eos_token = True
        tokenizer.add_bos_token, tokenizer.add_eos_token

        # Set PEFT adapter config (16:32)
        from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training

        # target modules are currently selected for zephyr base model
        config = LoraConfig(
            r= self.lora_r if self.lora_r else 16,
            lora_alpha= self.lora_alpha if self.lora_alpha else 32,
            target_modules=["q_proj", "v_proj","k_proj","o_proj","gate_proj","up_proj","down_proj"],   # target all the linear layers for full finetuning
            lora_dropout= self.lora_dropout if self.lora_dropout else 0.05,
            bias="none",
            task_type="CAUSAL_LM")

        # stabilize output layer and layernorms
        model = prepare_model_for_kbit_training(model, self.quantization)
        # Set PEFT adapter on model (Last step)
        model = get_peft_model(model, config)

        # Set Hyperparameters
        MAXLEN=512
        BATCH_SIZE = self.batch_size if self.batch_size else 4
        GRAD_ACC = self.gradient_accumulation if self.gradient_accumulation else 4
        OPTIMIZER ='paged_adamw_8bit' # save memory
        LR=self.lr if self.lr else 5e-06                       # slightly smaller than pretraining lr | and close to LoRA standard


        training_config = transformers.TrainingArguments(per_device_train_batch_size=BATCH_SIZE,
                                                        gradient_accumulation_steps=GRAD_ACC,
                                                        optim=OPTIMIZER,
                                                        learning_rate=LR,
                                                        fp16=True,            # consider compatibility when using bf16
                                                        logging_steps=10,
                                                        num_train_epochs = self.epoch if self.epoch else 2,
                                                        output_dir=lora_output,
                                                        remove_unused_columns=True,
                                                        )

        # Set collator
        data_collator = transformers.DataCollatorForLanguageModeling(tokenizer,mlm=False)

        # Setup trainer
        trainer = SFTTrainer(model=model,
                                    train_dataset=dataset,
                                    data_collator=data_collator,
                                    args=training_config,
                                    dataset_text_field="text",
                                    #    callbacks=[early_stop], need to learn, lora easily overfits
                                    )

        trainer.train()

        trainer.save_model(lora_output)

        # Get peft config
        from peft import PeftConfig
        config = PeftConfig.from_pretrained(lora_output)

        model = transformers.AutoModelForCausalLM.from_pretrained(config.base_model_name_or_path)

        # Load the Lora model
        from peft import PeftModel
        model = PeftModel.from_pretrained(model, lora_output)

        # Get tokenizer
        tokenizer = transformers.AutoTokenizer.from_pretrained(config.base_model_name_or_path)
        merged_model = model.merge_and_unload()

        merged_model.save_pretrained(full_output)
        tokenizer.save_pretrained(full_output)

