import os
import torch
import pandas as pd
import transformers
from transformers import AutoTokenizer
from pynvml import *
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from langchain.text_splitter import CharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS
from data_ret import data_ret_doc
from langchain import HuggingFacePipeline
from langchain import hub
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
path="models/full_KUET_LLM_zepyhr"
tokenizer = AutoTokenizer.from_pretrained(path,
                                          use_auth_token=True,)

model = AutoModelForCausalLM.from_pretrained(path,
                                             device_map='auto',
                                             torch_dtype=torch.float16,
                                             use_auth_token=True,
                                             load_in_8bit=True,
                                            #  load_in_4bit=True
                                             )

# model = AutoModelForCausalLM.from_pretrained(
#     path,
#     # quantization_config=bnb_config,
#     device_map="auto",
#     trust_remote_code=True,
#     attn_implementation="flash_attention_2",
#     torch_dtype=torch.bfloat16,

# )
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
retriever=vectorstore.as_retriever()
prompt = hub.pull("rlm/rag-prompt")
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
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


