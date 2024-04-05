from langchain_community.document_loaders import Docx2txtLoader
import glob
from langchain.text_splitter import CharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS
from ragatouille import RAGPretrainedModel
from langchain.retrievers import EnsembleRetriever
def create_vectorstore_mpnet(flag):
        if flag == False:
            flag=True
            all_doc=[]
            all_doc=[]
            directory_path = 'rag_data/'
            file_pattern = '*.docx'  
            file_paths = glob.glob(directory_path + file_pattern)
            print(file_paths,"*"*10)
            for x in file_paths:
                documents = Docx2txtLoader(x).load()
                all_doc.extend(documents)
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

def create_vectorstore_bai(flag):
    if flag == False:
        flag=True
        all_doc=[]
        directory_path = 'rag_data/'
        file_pattern = '*.docx'  
        file_paths = glob.glob(directory_path + file_pattern)
        for x in file_paths:
            loader = Docx2txtLoader(x)
            documents=loader.load()
            all_doc.extend(documents)
        text_splitter=CharacterTextSplitter(chunk_size=500,chunk_overlap=30,separator="\n")
        docs=text_splitter.split_documents(documents=all_doc)
        model_name = "BAAI/bge-large-en-v1.5"
        hf = HuggingFaceEmbeddings(model_name=model_name)
        vectorstore=FAISS.from_documents(docs,hf)
        vectorstore.save_local('vectorstore')
        return vectorstore
    else:
        model_name = "BAAI/bge-large-en-v1.5"
        hf = HuggingFaceEmbeddings(model_name=model_name)
        new_vectorstore=FAISS.load_local("vectorstore",hf)
        return new_vectorstore
def create_vectorstore_ensemble():
        directory_path = 'rag_data/'
        file_pattern = '*.docx'  
        file_paths = glob.glob(directory_path + file_pattern)
        all_doc=[]
        for x in file_paths:
            loader = Docx2txtLoader(x)
            documents=loader.load()
            all_doc.append(str(documents[0].page_content))
            docs='\n\n'.join(all_doc)
        RAG = RAGPretrainedModel.from_pretrained("colbert-ir/colbertv2.0")
        RAG.index(
            collection=[docs],
            index_name="llama_colbert",
            max_document_length=256,
            split_documents=True,
            )
        retriever1 = RAG.as_langchain_retriever(k=3)
        retriever2=create_vectorstore_bai(False).vectorstore.as_retriever()
        
        retriever = EnsembleRetriever(retrievers=[retriever1, retriever2],
                                            weights=[0.50, 0.50])
        return retriever