from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from langchain import HuggingFacePipeline
from transformers import pipeline
import transformers
import torch
from transformers import T5Tokenizer
from transformers import T5ForConditionalGeneration
def zepyhr_model(model_info,quanization):
    path=f"models/{model_info}"
    tokenizer = AutoTokenizer.from_pretrained(path,
                                            use_auth_token=True,)

    if quanization=="8":
        model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                load_in_8bit=True,                                        
                                                )
    else:
        model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                 load_in_4bit=True
                                                )

    pipe = pipeline("text-generation",
                    model=model,
                    tokenizer= tokenizer,
                    torch_dtype=torch.bfloat16,
                    device_map="auto",
                    max_new_tokens = 512,
                    do_sample=True,
                    top_k=30,
                    num_return_sequences=1,
                    eos_token_id=tokenizer.eos_token_id
                    )
        
    llm = HuggingFacePipeline(pipeline = pipe, model_kwargs = {'temperature':0})
    return llm
def llama_model(model_info,quanization):
    path=f"models/{model_info}"
    tokenizer = AutoTokenizer.from_pretrained(path,
                                            use_auth_token=True,)
    
    if quanization=="8":
        model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                load_in_8bit=True,
                                                )
    else:
        model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                 load_in_4bit=True
                                                )
    pipe = pipeline("text-generation",
                    model=model,
                    tokenizer= tokenizer,
                    torch_dtype=torch.bfloat16,
                    device_map="auto",
                    max_new_tokens = 512,
                    do_sample=True,
                    top_k=30,
                    num_return_sequences=1,
                    eos_token_id=tokenizer.eos_token_id
                    )
    llm = HuggingFacePipeline(pipeline = pipe, model_kwargs = {'temperature':0})
    return llm

def mistral_model(model_info,quanization):
    path=f"models/{model_info}"
    tokenizer = AutoTokenizer.from_pretrained(path,
                                            use_auth_token=True,)

    if quanization=="8":
        model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                load_in_8bit=True,
                                                )
    else:
        model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                 load_in_4bit=True
                                                )



    pipe = pipeline("text-generation",
                    model=model,
                    tokenizer= tokenizer,
                    torch_dtype=torch.bfloat16,
                    device_map="auto",
                    max_new_tokens = 512,
                    do_sample=True,
                    top_k=30,
                    num_return_sequences=1,
                    eos_token_id=tokenizer.eos_token_id
                    )
        
    llm = HuggingFacePipeline(pipeline = pipe, model_kwargs = {'temperature':0})
    return llm

def phi_model(model_info,quanization):
    path=f"models/{model_info}"
    tokenizer = AutoTokenizer.from_pretrained(path,
                                            use_auth_token=True,)

    if quanization=="8":
        model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                load_in_8bit=True,
                                                trust_remote_code=True
                                                )
    else:
        model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                 load_in_4bit=True,
                                                 trust_remote_code=True
                                                )



    pipe = pipeline("text-generation",
                    model=model,
                    tokenizer= tokenizer,
                    torch_dtype=torch.bfloat16,
                    device_map="auto",
                    max_new_tokens = 512,
                    do_sample=True,
                    top_k=30,
                    num_return_sequences=1,
                    eos_token_id=tokenizer.eos_token_id
                    )
        
    llm = HuggingFacePipeline(pipeline = pipe, model_kwargs = {'temperature':0})
    return llm

def flant5_model(model_info):
    path=f"models/{model_info}"
    model = T5ForConditionalGeneration.from_pretrained(path)
    MODEL_NAME = "google/flan-t5-base"
    tokenizer = T5Tokenizer.from_pretrained(MODEL_NAME)  
    pipe = pipeline("text-generation",
                    model=model,
                    tokenizer= tokenizer,
                    torch_dtype=torch.bfloat16,
                    device_map="auto",
                    max_new_tokens = 512,
                    do_sample=True,
                    top_k=30,
                    num_return_sequences=1,
                    eos_token_id=tokenizer.eos_token_id
                    )
        
    llm = HuggingFacePipeline(pipeline = pipe, model_kwargs = {'temperature':0})
    return tokenizer,model,llm

 # model = AutoModelForCausalLM.from_pretrained(
    #     path,
    #     # quantization_config=bnb_config,
    #     device_map="auto",
    #     trust_remote_code=True,
    #     attn_implementation="flash_attention_2",
    #     torch_dtype=torch.bfloat16,

    # )