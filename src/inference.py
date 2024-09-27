import os
import torch
import pandas as pd
import transformers
from pynvml import *
import torch
from langchain import hub
from model_ret import zephyr_model,llama_model,mistral_model,phi_model,flant5_model
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from create_retriever import ensemble_retriever
# HuggingFace model mapping
hf_model_map = {
    "Zephyr": "HuggingFaceH4/zephyr-7b-beta",
    "Llama": "NousResearch/Meta-Llama-3-8B",
    "Mistral": "unsloth/mistral-7b-instruct-v0.3",
    "Phi": "microsoft/Phi-3.5-mini-instruct",
    "Flant5": "google/flan-t5-base"
}

# Model chain class
class model_chain:
    model_name = ""

    def __init__(self, 
                 model_name_local, 
                 model_name_online="Llama", 
                 use_online=True, 
                 embedding_name="BAAI/bge-base-en-v1.5", 
                 splitter_type_dropdown="character", 
                 chunk_size_slider=512, 
                 chunk_overlap_slider=30, 
                 separator_textbox="\n", 
                 max_tokens_slider=2048) -> None:
        if not use_online and os.path.exists(f"models//{model_name_local}") and len(os.listdir(f"models//{model_name_local}")):
            import gradio as gr
            gr.Info("Model *()* from online!!")
            quantization, self.model_name = model_name_local.split("_")[0], model_name_local.split("_")[1]
            model_name_temp = model_name_local
        else:
            self.model_name = model_name_online
            model_name_temp = hf_model_map[model_name_online]
            quantization=4
            
        if self.model_name == "Zephyr":
            self.llm = zephyr_model(model_name_temp, quantization, use_online=use_online)
        elif self.model_name == "Llama":
            self.llm = llama_model(model_name_temp, quantization, use_online=use_online)
        elif self.model_name == "Mistral":
            self.llm = mistral_model(model_name_temp, quantization, use_online=use_online)
        elif self.model_name == "Phi":
            self.llm = phi_model(model_name_temp, quantization, use_online=use_online)
        elif self.model_name == "Flant5":
            self.tokenizer, self.model, self.llm = flant5_model(model_name_temp, use_online=use_online)

        # Creating the retriever
        self.retriever = ensemble_retriever(embedding_name,
                                            splitter_type=splitter_type_dropdown,
                                            chunk_size=chunk_size_slider,
                                            chunk_overlap=chunk_overlap_slider,
                                            separator=separator_textbox,
                                            max_tokens=max_tokens_slider)

        # Defining the RAG chain
        prompt = hub.pull("rlm/rag-prompt")
        self.rag_chain = (
            {"context": self.retriever | self.format_docs, "question": RunnablePassthrough()}
            | prompt
            | self.llm
            | StrOutputParser()
        )

    # Helper function to format documents
    def format_docs(self, docs):
        return "\n\n".join(doc.page_content for doc in docs)

    # Retrieve RAG chain
    def rag_chain_ret(self):
        return self.rag_chain

    # Answer retrieval function
    def ans_ret(self, inp, rag_chain):
        if self.model_name == 'Flant5':
            my_question = "What is KUET?"
            data = self.retriever.invoke(inp)
            context = ""
            for x in data[:2]:
                context += (x.page_content) + "\n"
            inputs = f"""Please answer to this question using this context:\n{context}\n{my_question}"""
            inputs = self.tokenizer(inputs, return_tensors="pt")
            outputs = self.model.generate(**inputs)
            answer = self.tokenizer.decode(outputs[0])
            from textwrap import fill
            ans = fill(answer, width=100)
            return ans

        ans = rag_chain.invoke(inp)
        ans = ans.split("Answer:")[1]
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




