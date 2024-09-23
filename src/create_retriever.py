import os
from langchain_community.document_loaders import Docx2txtLoader,TextLoader
import glob
from langchain.text_splitter import CharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS
from ragatouille import RAGPretrainedModel
from langchain.retrievers import EnsembleRetriever
from langchain.vectorstores import Chroma

def docs_return(flag):
    directory_path = 'rag_data/'
    docx_file_pattern = '*.docx'
    txt_file_pattern = '*.txt'
    
    # Get all docx and txt file paths
    docx_file_paths = glob.glob(directory_path + docx_file_pattern)
    txt_file_paths = glob.glob(directory_path + txt_file_pattern)
    
    all_doc, all_doc2 = [], []
    
    # Load .docx files
    for x in docx_file_paths:
        loader = Docx2txtLoader(x)
        documents = loader.load()
        all_doc.extend(documents)
        all_doc2.append(str(documents[0].page_content))
    
    # Load .txt files
    for x in txt_file_paths:
        loader = TextLoader(x)
        documents = loader.load()
        all_doc.extend(documents)
        all_doc2.append(str(documents[0].page_content))
    
    docs = '\n\n'.join(all_doc2)

    if flag == 0:
        return all_doc
    else:
        return docs

# Function to check if the model exists in the embedding folder or download it if not
def get_embedding_model(model_name):
    local_model_path = f"embedding_model/{model_name.replace('/', '_')}"
    
    if os.path.exists(local_model_path):
        print(f"Loading local model from {local_model_path}")
        return HuggingFaceEmbeddings(model_name=local_model_path)
    else:
        print(f"Downloading model {model_name}")
        return HuggingFaceEmbeddings(model_name=model_name)

# Flexibility to change the embedding model in retriever_chroma
def retriever_chroma(flag, model_name="BAAI/bge-large-en-v1.5"):
    embeddings = get_embedding_model(model_name)
    
    if flag == False:
        all_doc = docs_return(0)
        text_splitter = CharacterTextSplitter(chunk_size=500, chunk_overlap=30, separator="\n")
        docs = text_splitter.split_documents(documents=all_doc)
        vectordb = Chroma.from_documents(docs, embeddings, persist_directory="./chroma_db")
        chroma_retriever = vectordb.as_retriever(
            search_type="mmr", search_kwargs={"k": 4, "fetch_k": 10}
        )
        return chroma_retriever
    else:
        vectordb = Chroma.load_local("vectorstore", embeddings)
        chroma_retriever = vectordb.as_retriever(
            search_type="mmr", search_kwargs={"k": 4, "fetch_k": 10}
        )
        return chroma_retriever

def colbert_retriever():
    docs = docs_return(1)
    RAG = RAGPretrainedModel.from_pretrained("colbert-ir/colbertv2.0")
    RAG.index(
        collection=[docs],
        index_name="ensemble_colbert",
        max_document_length=256,
        split_documents=True,
    )
    retriever = RAG.as_langchain_retriever(k=3)
    return retriever

def ensemble_retriever(model_name="BAAI/bge-large-en-v1.5"):
    retriever1 = colbert_retriever()
    retriever2 = retriever_chroma(False, model_name=model_name)
    retriever = EnsembleRetriever(retrievers=[retriever1, retriever2], weights=[0.50, 0.50])
    return retriever

# Example usage:
# dat = ensemble_retriever(model_name="sentence-transformers/all-mpnet-base-v2")
# data = dat.invoke("What is KUET?")
# context = ""
# for x in data[:2]:
#     context += (x.page_content) + "\n"
