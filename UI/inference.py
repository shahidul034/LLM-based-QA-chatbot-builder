import os
import torch
import pandas as pd
import transformers
from pynvml import *
import torch
from langchain import hub
from model_ret import zepyhr_model,llama_model,mistral_model
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from create_retriever import ensemble_retriever
class model_chain:
    def __init__(self, model_name) -> None:
        if model_name=="Zepyhr":
            self.llm=zepyhr_model()
        elif model_name=="Llama2":
            self.llm=llama_model()
        else:
            self.llm=mistral_model()
        retriever=ensemble_retriever()
        prompt = hub.pull("rlm/rag-prompt")
        def format_docs(docs):
            return "\n\n".join(doc.page_content for doc in docs)
        self.rag_chain = (
            {"context": retriever | format_docs, "question": RunnablePassthrough()}
            | prompt
            | self.llm
            | StrOutputParser()
        )
        
    def rag_chain_ret(self):
        return self.rag_chain
        

    def ans_ret(self,inp,rag_chain):
        ans=rag_chain.invoke(inp)
        ans=ans.split("Answer:")[1]
        return ans
# def model_push(hf):
#     from transformers import AutoTokenizer, AutoModelForCausalLM
#     if model_name=="Mistral":
#         path="models/full_KUET_LLM_mistral"
#     elif model_name=="Zepyhr":
#         path="models/full_KUET_LLM_zepyhr"
#     elif model_name=="Llama2":
#         path="models/full_KUET_LLM_llama" 
#     tokenizer = AutoTokenizer.from_pretrained(path)
#     model = AutoModelForCausalLM.from_pretrained(path,
#                                                     device_map='auto',
#                                                     torch_dtype=torch.float16,
#                                                     use_auth_token=True,
#                                                     load_in_8bit=True,
#                                                     #  load_in_4bit=True
#                                                     )
#     model.push_to_hub(repo_id=f"My_model",token=hf)
#     tokenizer.push_to_hub(repo_id=f"My_model",token=hf)




