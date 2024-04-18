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
def rag_chain_ret(model_name):
    if model_name=="Zepyhr":
        llm=zepyhr_model()
    elif model_name=="Llama":
        llm=llama_model()
    elif model_name=="Mistral":
        llm=mistral_model()
    retriever=ensemble_retriever()
    prompt = hub.pull("rlm/rag-prompt")
    def format_docs(docs):
        return "\n\n".join(doc.page_content for doc in docs)
    rag_chain = (
        {"context": retriever | format_docs, "question": RunnablePassthrough()}
        | prompt
        | llm
        | StrOutputParser()
    )
    return rag_chain

def ans_ret(inp,rag_chain):
    ans=rag_chain.invoke(inp)
    k=ans.split("Based on the text material")
    k2=ans.split("Hope that helped! Let me know if you have any more questions.")

    if len(k)>=2:
        k3=k[0].split("Hope that helped! Let me know if you have any more questions.")
        if len(k3)>=2:
            return k3[0]
        else:
            return k[0]
    if len(k2)>=2:
        return k2[0]
    return ans
def model_push(model_name,hf):
    from transformers import AutoTokenizer, AutoModelForCausalLM
    if model_name=="Mistral":
        path="models/full_KUET_LLM_mistral"
    elif model_name=="Zepyhr":
        path="models/full_KUET_LLM_zepyhr"
    elif model_name=="Llama2":
        path="models/full_KUET_LLM_llama" 
    tokenizer = AutoTokenizer.from_pretrained(path)
    model = AutoModelForCausalLM.from_pretrained(path,
                                                    device_map='auto',
                                                    torch_dtype=torch.float16,
                                                    use_auth_token=True,
                                                    load_in_8bit=True,
                                                    #  load_in_4bit=True
                                                    )
    model.push_to_hub(repo_id=f"My_model_{model_name}",token=hf)
    tokenizer.push_to_hub(repo_id=f"My_model_{model_name}",token=hf)




