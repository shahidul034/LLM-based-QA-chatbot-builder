import pandas as pd
import datetime
import gradio as gr
import os
# It shows the demo data format in finetuning tab
def move_to(move,model_ans):
    df_temp=pd.read_excel(os.path.join("model_ans",str(model_ans)))
    id_temp=int((df_temp.loc[move])['id'])
    ques_temp=(df_temp.loc[move])['question']
    ans_temp=(df_temp.loc[move])['answer']
    if int(move)>=len(df_temp)+1:
        gr.Info(f"Number of questions: {len(df_temp)}")
        move=0
    return [
        gr.Label(value=str(id_temp),label="ID"),
        gr.Label(value=ques_temp,label="Question"),
        gr.Label(value=ans_temp,label="Answer")
    ]
def display_table(path=r"data/demo_table_data.xlsx"):
    df = pd.read_excel(path)
    df_with_custom_index = df.head(2)
    # df_with_custom_index.index = [f"Row {i+1}" for i in range(len(df_with_custom_index))]
    html_table = df_with_custom_index.to_html(index=False)
    return f"<div style='overflow-x:auto;'>{html_table}</div>"
def current_time():
    # ff="model_ans_llama_finetuned486_rag_ensemble"
    # df=pd.read_excel(r"model_ans/model_ans_mistral_finetuned486_rag_ensemble.xlsx")
    current_datetime = datetime.datetime.now()
    # file_name = current_datetime.strftime("%Y_%m_%d_%H_%M_%S")+ff
    return current_datetime.strftime("%Y_%m_%d_%H_%M_%S")
# This function use in human evaluation
def random_ques_ans2():
    import random
    import pandas as pd
    df=pd.read_excel(r"data/existing_dataset.xlsx")
    id=random.randint(0,len(df))
    ques_temp=(df.loc[id])['question']
    ans_temp=""
    return ques_temp,ans_temp
def score_report_bar():
    path="score_report"
    import os
    import math
    dat=[]
    for x in os.listdir(path):
        wh=[]
        flag=0
        for x2 in x:
            if x2>='a' and x2<='z':
                flag=1
                wh.append(x2)
            elif flag==1:
                wh.append(" ")
        wh=''.join(wh)
        wh=wh.replace("model ans","")
        wh=wh.replace("finetuned","")
        wh=wh.replace("  "," ")
        wh=wh.replace("xlsx","")
        df_temp=pd.read_excel(os.path.join(path,x))
        rating=sum(df_temp["rating"])/len(df_temp)
        dat.append({
            "Model Name":wh,
            "Average Rating":rating
        })
    temp=pd.DataFrame(dat)
    return temp
def parse_data(link,progress):    
    from bs4 import BeautifulSoup
    import requests
    import re
    from docx import Document       
    from langchain_community.document_loaders import WebBaseLoader
    s=set()
    import time
    start_time = time.time()
    duration = 5
    def get_links(url):
        response = requests.get(url)
        data = response.text
        soup = BeautifulSoup(data, 'lxml')

        links = []
        for link in soup.find_all('a'):
            link_url = link.get('href')
            if link_url is not None and link_url.startswith('http'):
                s.add(link_url)
                links.append(link_url)
        
        return links
    # def write_to_file(links):
    #     with open('data.txt', 'a') as f:
    #         f.writelines(links)
    def get_all_links(url):
            for link in get_links(url):
                if (time.time() - start_time) >= duration:
                    return
                get_all_links(link)

    def data_ret2(link):
        loader = WebBaseLoader(f"{link}")
        data = loader.load()
        return data[0].page_content
    # link = 'https://kuet.ac.bd'
    s.add(link)
    get_all_links(link)
    li=list(s)
    all_data=[]
    for x in progress.tqdm(li):
        try:
            print("Link: ",x)
            all_data.append(data_ret2(x))
        except:
            print("pass")
            continue
    all_data2 = re.sub(r'\n+', '\n\n', "\n".join(all_data))
    all_data2=re.sub(u'[^\u0020-\uD7FF\u0009\u000A\u000D\uE000-\uFFFD\U00010000-\U0010FFFF]+', '', all_data2)
    document = Document()
    document.add_paragraph(all_data2)
    document.save(r'rag_data\rag_data.docx')
    print("Finished!!")
    return
def all_contri_ans(id, ques):
    folder_path = 'save_ques_ans'
    data_frames = []
    for filename in os.listdir(folder_path):
        if filename.endswith(".xlsx") or filename.endswith(".xls"):
            file_path = os.path.join(folder_path, filename)
            df = pd.read_excel(file_path)
            data_frames.append(df)       
            
    df_hum = pd.concat(data_frames, ignore_index=True)
    temp=[]
    for x,y in zip(df_hum['question'],df_hum['answer']):
        if x==ques:
            temp.append(y)
    if len(temp)==0:
        temp=["This question's answer is not available."]
    return temp  
  