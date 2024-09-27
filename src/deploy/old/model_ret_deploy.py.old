from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from langchain import HuggingFacePipeline
from transformers import pipeline
import transformers
import torch
def model_ret(path):

    tokenizer = AutoTokenizer.from_pretrained(path,
                                            use_auth_token=True,)

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

