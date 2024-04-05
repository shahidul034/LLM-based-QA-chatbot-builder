from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from langchain import HuggingFacePipeline
from transformers import pipeline
import transformers
import torch
def zepyhr_model():
    path="models/full_KUET_LLM_zepyhr"
    tokenizer = AutoTokenizer.from_pretrained(path,
                                            use_auth_token=True,)

    # model = AutoModelForCausalLM.from_pretrained(
    #     path,
    #     # quantization_config=bnb_config,
    #     device_map="auto",
    #     trust_remote_code=True,
    #     attn_implementation="flash_attention_2",
    #     torch_dtype=torch.bfloat16,

    # )
    model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                load_in_8bit=True,
                                                #  load_in_4bit=True
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
def llama_model():
    base_model = "NousResearch/Llama-2-7b-chat-hf"
    full_output = 'models/full_KUET_LLM_llama'
    tokenizer = transformers.AutoTokenizer.from_pretrained(base_model)
    pipe = pipeline("text-generation",
                    model=full_output,
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

def mistral_model():
    path="models/full_KUET_LLM_mistral"
    tokenizer = AutoTokenizer.from_pretrained(path,
                                            use_auth_token=True,)

    # model = AutoModelForCausalLM.from_pretrained(
    #     path,
    #     # quantization_config=bnb_config,
    #     device_map="auto",
    #     trust_remote_code=True,
    #     attn_implementation="flash_attention_2",
    #     torch_dtype=torch.bfloat16,

    # )
    model = AutoModelForCausalLM.from_pretrained(path,
                                                device_map='auto',
                                                torch_dtype=torch.float16,
                                                use_auth_token=True,
                                                load_in_8bit=True,
                                                #  load_in_4bit=True
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
