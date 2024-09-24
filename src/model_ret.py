from transformers import AutoTokenizer, AutoModelForCausalLM, T5Tokenizer, T5ForConditionalGeneration, pipeline
from langchain import HuggingFacePipeline
import os
import torch

def load_model_and_pipeline(model_info, quantization=4, is_t5=False, use_local=True):
    # Check if the model is local or should be downloaded from Hugging Face
    # if use_local:
    #     path = f"models/{model_info}"
    #     if not os.path.exists(path):
    #         print(f"Local model not found at {path}. Downloading from Hugging Face...")
    #         use_local = False  # Fallback to Hugging Face download if local not found
    # if not use_local:
    #     # Replace model_info with the corresponding Hugging Face repo name
    #     hf_model_map = {
    #         "zephyr-7b-beta": "HuggingFaceH4/zephyr-7b-beta",
    #         "llama-3-8b": "NousResearch/Meta-Llama-3-8B",
    #         "mistral-7b": "unsloth/mistral-7b-instruct-v0.3",
    #         "phi-3-mini": "microsoft/Phi-3-mini-4k-instruct",
    #         "flan-t5-base": "google/flan-t5-base"
    #     }
    #     path = hf_model_map.get(model_info.split("_")[1], model_info)

    tokenizer = AutoTokenizer.from_pretrained(model_info, use_auth_token=True)

    if quantization == "8":
        model = AutoModelForCausalLM.from_pretrained(
            model_info,
            device_map='auto',
            torch_dtype=torch.float16,
            use_auth_token=True,
            load_in_8bit=True
        )
    else:
        model = AutoModelForCausalLM.from_pretrained(
            model_info,
            device_map='auto',
            torch_dtype=torch.float16,
            use_auth_token=True,
            load_in_4bit=True
        )

    if is_t5:
        model = T5ForConditionalGeneration.from_pretrained(model_info)
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

def zephyr_model(model_info, quantization, use_local=True):
    return load_model_and_pipeline(model_info, quantization, use_local=use_local)

def llama_model(model_info, quantization, use_local=True):
    return load_model_and_pipeline(model_info, quantization, use_local=use_local)

def mistral_model(model_info, quantization, use_local=True):
    return load_model_and_pipeline(model_info, quantization, use_local=use_local)

def phi_model(model_info, quantization, use_local=True):
    return load_model_and_pipeline(model_info, quantization, use_local=use_local)

def flant5_model(model_info, use_local=True):
    return load_model_and_pipeline(model_info, is_t5=True, use_local=use_local)
