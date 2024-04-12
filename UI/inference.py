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




