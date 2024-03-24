from langchain_community.document_loaders import WebBaseLoader
def data_ret():
    start=1
    full_data=[]
    while True:
        loader = WebBaseLoader(f"https://github.com/shahidul034/Misc-project/blob/main/KUET%20LLM/KUET%20LLM%20RAG%20data/rag{start}.txt")
        data = loader.load()
        full_data.extend(data)
        start+=1
        if (data[0].page_content)=="404: Not Found":
            break

    return full_data
def dat_ret_str():
    start=1
    full_data=[]
    while True:
        loader = WebBaseLoader(f"https://github.com/shahidul034/Misc-project/blob/main/KUET%20LLM/KUET%20LLM%20RAG%20data/rag{start}.txt")
        data = loader.load()
        full_data.extend(data[0].page_content)
        start+=1
        if (data[0].page_content)=="404: Not Found":
            break
    docs="\n\n".join(full_data)
    return docs