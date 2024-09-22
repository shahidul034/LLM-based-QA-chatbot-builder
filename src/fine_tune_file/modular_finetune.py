import os
import torch
from datetime import datetime
from datasets import Dataset
import pandas as pd
import transformers
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig, T5Tokenizer, T5ForConditionalGeneration
from trl import SFTTrainer
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training, PeftConfig, PeftModel
import os
cache_folder="/mnt/FA00A16100A1259B/shakib/model_cache"
# os.environ['HF_HOME'] = cache_folder
# os.environ['HF_DATASETS_CACHE'] = cache_folder
# os.environ['TRANSFORMERS_CACHE'] = cache_folder
# print("*"*20)
# print(os.environ['HF_HOME'])
# print(os.environ['HF_DATASETS_CACHE'])
# print(os.environ['TRANSFORMERS_CACHE'])
# print(os.path.isdir(cache_folder))
# assert(False)
class BaseTrainer:
    def __init__(self, model_name, base_model):
        self.model_name = model_name
        self.base_model = base_model
        self.tokenizer = self.load_tokenizer()
        self.model = self.load_model()

    def load_tokenizer(self):
        tokenizer = AutoTokenizer.from_pretrained(self.base_model, trust_remote_code=True)
        tokenizer.padding_side = 'right'
        tokenizer.pad_token = tokenizer.eos_token
        return tokenizer

    def load_model(self):
        raise NotImplementedError("Subclasses must implement load_model method")

    def preprocess_function(self, examples):
        raise NotImplementedError("Subclasses must implement preprocess_function method")

    def formatted_text(self, x):
        self.tokenizer.chat_template = {
                "role": "user",
                "content": "You are a helpful chatbot. Question: {question}\nAnswer: {answer}"
            }
        temp = [
            {"role": "user", "content": f"You are a helpful chatbot, help users by answering their queries.\nQuestion: {x['question']}"},
            {"role": "assistant", "content": x["answer"]}
        ]
        return self.tokenizer.apply_chat_template(temp, add_generation_prompt=False, tokenize=False,chat_template='content')

    def train(self, lr, epoch, batch_size, gradient_accumulation, quantization, lora_r, lora_alpha, lora_dropout):
        data_location = "data/finetune_data.xlsx"
        data_df = pd.read_excel(data_location)
        data_df["text"] = data_df[["question", "answer"]].apply(lambda x: self.formatted_text(x), axis=1)
        dataset = Dataset.from_pandas(data_df)

        lora_output = f'models/{quantization}_{self.model_name}_lora_{datetime.now().strftime("%Y_%m_%d_%H_%M_%S")}'
        full_output = f'models/{quantization}_{self.model_name}_full_{datetime.now().strftime("%Y_%m_%d_%H_%M_%S")}'

        config = LoraConfig(
            r=lora_r or 16,
            lora_alpha=lora_alpha or 32,
            target_modules=["q_proj", "v_proj", "k_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
            lora_dropout=lora_dropout or 0.05,
            bias="none",
            task_type="CAUSAL_LM"
        )

        self.model = prepare_model_for_kbit_training(self.model)
        self.model = get_peft_model(self.model, config)

        training_args = transformers.TrainingArguments(
            per_device_train_batch_size=batch_size or 4,
            gradient_accumulation_steps=gradient_accumulation or 4,
            optim='paged_adamw_8bit',
            learning_rate=lr or 5e-6,
            fp16=True,
            logging_steps=10,
            num_train_epochs=epoch or 2,
            output_dir=lora_output,
            remove_unused_columns=True,
        )

        data_collator = transformers.DataCollatorForLanguageModeling(self.tokenizer, mlm=False)

        trainer = SFTTrainer(
            model=self.model,
            train_dataset=dataset,
            data_collator=data_collator,
            args=training_args,
            dataset_text_field="text",
        )

        trainer.train()
        trainer.save_model(lora_output)

        config = PeftConfig.from_pretrained(lora_output)
        model = AutoModelForCausalLM.from_pretrained(config.base_model_name_or_path)
        model = PeftModel.from_pretrained(model, lora_output)

        merged_model = model.merge_and_unload()
        merged_model.save_pretrained(full_output)
        self.tokenizer.save_pretrained(full_output)
        print("*" * 10, ": Model is saved!!!")

class LlamaTrainer(BaseTrainer):
    def load_model(self):
        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_use_double_quant=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.bfloat16
        )
        model = AutoModelForCausalLM.from_pretrained(
            self.base_model,
            quantization_config=bnb_config,
            torch_dtype=torch.bfloat16,
            device_map="auto",
            trust_remote_code=True,
            cache_dir=cache_folder
        )
        model.config.use_cache = False
        model.config.pretraining_tp = 1
        model.gradient_checkpointing_enable()
        return model

class MistralTrainer(BaseTrainer):
    def load_model(self):
        return LlamaTrainer.load_model(self)

class PhiTrainer(BaseTrainer):
    def load_model(self):
        return LlamaTrainer.load_model(self)

class ZephyrTrainer(BaseTrainer):
    def load_model(self):
        return LlamaTrainer.load_model(self)

class FlanT5Trainer(BaseTrainer):
    def load_tokenizer(self):
        tokenizer = T5Tokenizer.from_pretrained(self.base_model)
        tokenizer.padding_side = 'right'
        return tokenizer

    def load_model(self):
        model = T5ForConditionalGeneration.from_pretrained(self.base_model)
        return model

    def preprocess_function(self, examples):
        prefix = "Please answer this question: "
        inputs = [prefix + doc for doc in examples["question"]]
        model_inputs = self.tokenizer(inputs, max_length=1024, truncation=True)
        labels = self.tokenizer(text_target=examples["answer"], max_length=1024, truncation=True)
        model_inputs["labels"] = labels["input_ids"]
        return model_inputs

def get_trainer(model_name):
    model_map = {
        "llama": ("NousResearch/Meta-Llama-3-8B", LlamaTrainer),
        "mistral": ("unsloth/mistral-7b-instruct-v0.3", MistralTrainer),
        "phi": ("microsoft/Phi-3-mini-4k-instruct", PhiTrainer),
        "zephyr": ("HuggingFaceH4/zephyr-7b-beta", ZephyrTrainer),
        "flan-t5": ("google/flan-t5-base", FlanT5Trainer),
    }
    
    base_model, trainer_class = model_map.get(model_name.lower(), (None, None))
    if not base_model or not trainer_class:
        raise ValueError(f"Unsupported model: {model_name}")
    
    return trainer_class(model_name, base_model)

def main():
    # Example usage
    model_name = "llama"  # or "mistral", "phi", "zephyr", "flan-t5"
    trainer = get_trainer(model_name)
    trainer.train(lr=5e-6, epoch=2, batch_size=4, gradient_accumulation=4, quantization=8, lora_r=16, lora_alpha=32, lora_dropout=0.05)

if __name__ == "__main__":
    main()