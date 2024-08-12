import os
import torch
import pandas as pd
import transformers
from pynvml import *
import torch
from langchain import hub
from model_ret import zepyhr_model,llama_model,mistral_model,phi_model,flant5_model
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from create_retriever import ensemble_retriever
class model_chain:
    model_name=""
    def __init__(self, model_info) -> None:
        quantization,self.model_name=model_info.split("_")[0],model_info.split("_")[1]
        if self.model_name=="Zepyhr":
            self.llm=zepyhr_model(model_info,quantization)
        elif self.model_name=="Llama":
            self.llm=llama_model(model_info,quantization)
        elif self.model_name=="Mistral":
            self.llm=mistral_model(model_info,quantization)
        elif self.model_name=="Phi":
            self.llm=phi_model(model_info,quantization)
        elif self.model_name=="flant5":
            self.tokenizer, self.model,self.llm=flant5_model(model_info)    
        self.retriever=ensemble_retriever()
        prompt = hub.pull("rlm/rag-prompt")
        def format_docs(docs):
            return "\n\n".join(doc.page_content for doc in docs)
        self.rag_chain = (
            {"context": self.retriever | format_docs, "question": RunnablePassthrough()}
            | prompt
            | self.llm
            | StrOutputParser()
        )
        
    def rag_chain_ret(self):
        return self.rag_chain
        
    def ans_ret(self,inp,rag_chain):
        
        if self.model_name=='flant5':
            my_question = "What is KUET?"
            data=self.retriever.invoke(inp)
            context=""
            for x in data[:2]:
                context+=(x.page_content)+"\n"
            inputs = f"""Please answer to this question using this context:\n{context}\n{my_question}"""
            inputs = self.tokenizer(inputs, return_tensors="pt")
            outputs = self.model.generate(**inputs)
            answer = self.tokenizer.decode(outputs[0])
            from textwrap import fill
            ans=fill(answer, width=100)
            return ans
            
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




