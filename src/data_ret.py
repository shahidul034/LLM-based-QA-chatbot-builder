from langchain_community.document_loaders import WebBaseLoader
def data_ret2(link):
    start=1
    loader = WebBaseLoader(f"{link}")
    data = loader.load()
    return data