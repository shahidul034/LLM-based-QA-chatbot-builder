import os
import torch
import pandas as pd
import transformers
from pynvml import *
import torch
from langchain.text_splitter import CharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS
from data_ret import data_ret_doc
from langchain import hub
from model_ret import zepyhr_model
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
def create_vectorstore(flag):
    if flag == False:
        flag=True
        all_doc=[]
        all_doc=data_ret_doc()
        text_splitter=CharacterTextSplitter(chunk_size=500,chunk_overlap=30,separator="\n")
        docs=text_splitter.split_documents(documents=all_doc)
        model_name = "sentence-transformers/all-mpnet-base-v2"
        hf = HuggingFaceEmbeddings(model_name=model_name)
        vectorstore=FAISS.from_documents(docs,hf)
        vectorstore.save_local('vectorstore')
        return vectorstore
    else:
        model_name = "sentence-transformers/all-mpnet-base-v2"
        hf = HuggingFaceEmbeddings(model_name=model_name)
        new_vectorstore=FAISS.load_local("vectorstore",hf)
        return new_vectorstore

vectorstore=create_vectorstore(False)
llm=zepyhr_model()
retriever=vectorstore.as_retriever()
prompt = hub.pull("rlm/rag-prompt")
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)

def ans_ret(inp,history):
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

ans=ans_ret("What is KUET?","")


