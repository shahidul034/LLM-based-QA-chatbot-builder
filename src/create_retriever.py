from langchain_community.document_loaders import Docx2txtLoader
import glob
from langchain.text_splitter import CharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS
from ragatouille import RAGPretrainedModel
from langchain.retrievers import EnsembleRetriever
from langchain.vectorstores import Chroma
def docs_return(flag):
    directory_path,file_pattern = 'rag_data/','*.docx'  
    file_paths = glob.glob(directory_path + file_pattern)
    all_doc,all_doc2=[],[]
    for x in file_paths:
            loader = Docx2txtLoader(x)
            documents=loader.load()
            all_doc.extend(documents)
            all_doc2.append(str(documents[0].page_content))
            docs='\n\n'.join(all_doc2)
            
    if flag==0:
        return all_doc
    else:
         return docs
# def mpnet_retriever(flag):
#         if flag == False:
#             all_doc=docs_return(0)
#             text_splitter=CharacterTextSplitter(chunk_size=500,chunk_overlap=30,separator="\n")
#             docs=text_splitter.split_documents(documents=all_doc)
#             model_name = "sentence-transformers/all-mpnet-base-v2"
#             hf = HuggingFaceEmbeddings(model_name=model_name)
#             vectorstore=FAISS.from_documents(docs,hf)
#             retriever=vectorstore.as_retriever()
#             vectorstore.save_local('vectorstore')
#             return retriever
#         else:
#             model_name = "sentence-transformers/all-mpnet-base-v2"
#             hf = HuggingFaceEmbeddings(model_name=model_name)
#             new_vectorstore=FAISS.load_local("vectorstore",hf)
#             retriever=new_vectorstore.as_retriever()
#             return retriever

# def bai_retriever_faiss(flag):
#     if flag == False:
#         all_doc=docs_return(0)
#         text_splitter=CharacterTextSplitter(chunk_size=500,chunk_overlap=30,separator="\n")
#         docs=text_splitter.split_documents(documents=all_doc)
#         hf = HuggingFaceEmbeddings(model_name="BAAI/bge-large-en-v1.5")
#         vectorstore=FAISS.from_documents(docs,hf)
#         retriever=vectorstore.as_retriever()
#         vectorstore.save_local('vectorstore')
#         return retriever
#     else:
#         model_name = "BAAI/bge-large-en-v1.5"
#         hf = HuggingFaceEmbeddings(model_name=model_name)
#         new_vectorstore=FAISS.load_local("vectorstore",hf)
#         retriever=new_vectorstore.as_retriever()
#         return retriever

def bai_retriever_chroma(flag):
    if flag == False:
        all_doc=docs_return(0)
        text_splitter=CharacterTextSplitter(chunk_size=500,chunk_overlap=30,separator="\n")
        docs=text_splitter.split_documents(documents=all_doc)
        embeddings = HuggingFaceEmbeddings(model_name="BAAI/bge-large-en-v1.5")
        vectordb = Chroma.from_documents(docs, embeddings,persist_directory="./chroma_db")
        # vectordb.save_local('vectorstore')
        chroma_retriever = vectordb.as_retriever(
            search_type="mmr", search_kwargs={"k": 4, "fetch_k": 10}
        )
        return chroma_retriever
    else:
        model_name = "BAAI/bge-large-en-v1.5"
        hf = HuggingFaceEmbeddings(model_name=model_name)
        vectordb=Chroma.load_local("vectorstore",hf)
        chroma_retriever = vectordb.as_retriever(
            search_type="mmr", search_kwargs={"k": 4, "fetch_k": 10}
        )
        return chroma_retriever


def colbert_retriever():
    docs=docs_return(1)
    RAG = RAGPretrainedModel.from_pretrained("colbert-ir/colbertv2.0")
    RAG.index(
            collection=[docs],
            index_name="ensemble_colbert",
            max_document_length=256,
            split_documents=True,
            )
    retriever = RAG.as_langchain_retriever(k=3)
    return retriever
def ensemble_retriever():
        retriever1=colbert_retriever()
        retriever2=bai_retriever_chroma(False)
        retriever = EnsembleRetriever(retrievers=[retriever1, retriever2],
                                            weights=[0.50, 0.50])
        return retriever
# dat=ensemble_retriever()
# data=dat.invoke("What is KUET?")
# context=""
# for x in data[:2]:
#     context+=(x.page_content)+"\n"