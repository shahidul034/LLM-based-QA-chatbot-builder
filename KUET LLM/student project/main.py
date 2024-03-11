from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.document_loaders import PyPDFLoader, DirectoryLoader
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS
import chainlit as cl
import os

DATA_PATH = "data/"
DB_FAISS_PATH = "vectorstores/db_faiss"

@cl.on_chat_start
async def on_chat_start():
    while True:
        files = None

        # Wait for the user to upload a PDF file
        while files is None:
            files = await cl.AskFileMessage(
                content="Please upload a PDF file to save.",
                accept=["application/pdf"],
                max_size_mb=100,
                timeout=180,
            ).send()

        # Save the PDF file to the data directory
        file = files[0]
        pdf_path = os.path.join(DATA_PATH, file.name)
        with open(pdf_path, "wb") as pdf_file:
            pdf_file.write(file.content)
        loader = DirectoryLoader(DATA_PATH, glob='*.pdf', loader_cls=PyPDFLoader)
        documents = loader.load()
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
        texts = text_splitter.split_documents(documents)

        embeddings = HuggingFaceEmbeddings(model_name='sentence-transformers/all-MiniLM-L6-v2')
        model_kwargs = {'device': 'cpu'}
        db = FAISS.from_documents(texts, embeddings)
        db.save_local(DB_FAISS_PATH)

        msg = cl.Message(content=f"PDF file `{file.name}` uploaded successfully. Upload another PDF?")
        

if __name__ == "__main__":
    cl.run_chat()
