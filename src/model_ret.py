from transformers import AutoTokenizer, AutoModelForCausalLM, T5Tokenizer, T5ForConditionalGeneration, pipeline
from langchain import HuggingFacePipeline
import torch

def load_model_and_pipeline(model_info, quantization=None, is_t5=False):
    path = f"models/{model_info}"
    tokenizer = AutoTokenizer.from_pretrained(path, use_auth_token=True)

    if quantization == "8":
        model = AutoModelForCausalLM.from_pretrained(
            path,
            device_map='auto',
            torch_dtype=torch.float16,
            use_auth_token=True,
            load_in_8bit=True
        )
    else:
        model = AutoModelForCausalLM.from_pretrained(
            path,
            device_map='auto',
            torch_dtype=torch.float16,
            use_auth_token=True,
            load_in_4bit=True
        )

    if is_t5:
        model = T5ForConditionalGeneration.from_pretrained(path)
        tokenizer = T5Tokenizer.from_pretrained("google/flan-t5-base")

    pipe = pipeline(
        "text-generation",
        model=model,
        tokenizer=tokenizer,
        torch_dtype=torch.bfloat16,
        device_map="auto",
        max_new_tokens=512,
        do_sample=True,
        top_k=30,
        num_return_sequences=1,
        eos_token_id=tokenizer.eos_token_id
    )

    llm = HuggingFacePipeline(pipeline=pipe, model_kwargs={'temperature': 0})
    return tokenizer, model, llm

def zephyr_model(model_info, quantization):
    return load_model_and_pipeline(model_info, quantization)

def llama_model(model_info, quantization):
    return load_model_and_pipeline(model_info, quantization)

def mistral_model(model_info, quantization):
    return load_model_and_pipeline(model_info, quantization)

def phi_model(model_info, quantization):
    return load_model_and_pipeline(model_info, quantization)

def flant5_model(model_info):
    return load_model_and_pipeline(model_info, is_t5=True)
