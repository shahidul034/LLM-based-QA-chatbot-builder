import os
import glob
from langchain_community.document_loaders import Docx2txtLoader, TextLoader
from langchain.text_splitter import CharacterTextSplitter, RecursiveCharacterTextSplitter, TokenTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import Chroma
from langchain.retrievers import EnsembleRetriever
# from ragatouille import RAGPretrainedModel

# Function to load and process documents
def docs_return(flag):
    directory_path = 'rag_data/'
    docx_file_pattern = '*.docx'
    txt_file_pattern = '*.txt'
    
    docx_file_paths = glob.glob(directory_path + docx_file_pattern)
    txt_file_paths = glob.glob(directory_path + txt_file_pattern)
    
    all_doc, all_doc2 = [], []
    
    for x in docx_file_paths:
        loader = Docx2txtLoader(x)
        documents = loader.load()
        all_doc.extend(documents)
        all_doc2.append(str(documents[0].page_content))
    
    for x in txt_file_paths:
        loader = TextLoader(x)
        documents = loader.load()
        all_doc.extend(documents)
        all_doc2.append(str(documents[0].page_content))
    
    docs = '\n\n'.join(all_doc2)
    
    return all_doc if flag == 0 else docs

# Function to get or download the embedding model
def get_embedding_model(model_name):
    local_model_path = f"embedding_model/{model_name.replace('/', '_')}"
    if os.path.exists(local_model_path):
        print(f"Loading local model from {local_model_path}")
        return HuggingFaceEmbeddings(model_name=local_model_path)
    else:
        print(f"Downloading model {model_name}")
        return HuggingFaceEmbeddings(model_name=model_name)

# Function to return different types of text splitters
def get_text_splitter(splitter_type='character', chunk_size=500, chunk_overlap=30, separator="\n", max_tokens=1000):
    if splitter_type == 'character':
        return CharacterTextSplitter(chunk_size=chunk_size, chunk_overlap=chunk_overlap, separator=separator)
    elif splitter_type == 'recursive':
        return RecursiveCharacterTextSplitter(chunk_size=chunk_size, chunk_overlap=chunk_overlap)
    elif splitter_type == 'token':
        return TokenTextSplitter(chunk_size=max_tokens, chunk_overlap=chunk_overlap)
    else:
        raise ValueError("Unsupported splitter type. Choose from 'character', 'recursive', or 'token'.")

# Retriever using Chroma and HuggingFace embeddings
def retriever_chroma(flag, model_name="BAAI/bge-large-en-v1.5", splitter_type='character', chunk_size=500, chunk_overlap=30, separator="\n", max_tokens=1000):
    # Load or download the embedding model
    embeddings = get_embedding_model(model_name)
    
    if not flag:
        # Load the documents
        all_doc = docs_return(0)
        
        # Use the splitter parameters
        text_splitter = get_text_splitter(splitter_type=splitter_type, chunk_size=chunk_size, chunk_overlap=chunk_overlap, separator=separator, max_tokens=max_tokens)
        
        # Split the documents using the text splitter
        docs = text_splitter.split_documents(documents=all_doc)
        
        # Create a Chroma vector database
        vectordb = Chroma.from_documents(docs, embeddings, persist_directory="./chroma_db")
        
        # Create the retriever
        chroma_retriever = vectordb.as_retriever(
            search_type="mmr", search_kwargs={"k": 4, "fetch_k": 10}
        )
        return chroma_retriever
    else:
        # Load a local Chroma vectorstore
        vectordb = Chroma.load_local("vectorstore", embeddings)
        chroma_retriever = vectordb.as_retriever(
            search_type="mmr", search_kwargs={"k": 4, "fetch_k": 10}
        )
        return chroma_retriever

# ColBERT retriever
# def colbert_retriever():
#     docs = docs_return(1)
#     RAG = RAGPretrainedModel.from_pretrained("colbert-ir/colbertv2.0")
#     RAG.index(
#         collection=[docs],
#         index_name="ensemble_colbert",
#         max_document_length=256,
#         split_documents=True,
#     )
#     retriever = RAG.as_langchain_retriever(k=3)
#     return retriever

# Ensemble retriever
# def ensemble_retriever(model_name="BAAI/bge-large-en-v1.5", splitter_type='character', chunk_size=500, chunk_overlap=30, separator="\n", max_tokens=1000):
#     retriever1 = colbert_retriever()
#     retriever2 = retriever_chroma(False, model_name=model_name, splitter_type=splitter_type, chunk_size=chunk_size, chunk_overlap=chunk_overlap, separator=separator, max_tokens=max_tokens)
#     retriever = EnsembleRetriever(retrievers=[retriever1, retriever2], weights=[0.50, 0.50])
#     return retriever

# Example usage:
# dat = ensemble_retriever(model_name="sentence-transformers/all-mpnet-base-v2", splitter_type='token', chunk_size=500)
# data = dat.invoke("What is KUET?")
# context = ""
# for x in data[:2]:
#     context += (x.page_content) + "\n"
