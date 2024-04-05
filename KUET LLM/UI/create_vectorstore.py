from langchain_community.document_loaders import Docx2txtLoader
import glob
from langchain.text_splitter import CharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS
def create_vectorstore(flag):
        if flag == False:
            flag=True
            all_doc=[]
            all_doc=[]
            directory_path = 'rag_data'
            file_pattern = '*.docx'  
            file_paths = glob.glob(directory_path + file_pattern)
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