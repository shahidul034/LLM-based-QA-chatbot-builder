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
def display_table():
    df = pd.read_excel(r"data/demo_table_data.xlsx")
    df_with_custom_index = df.head(2)
    # df_with_custom_index.index = [f"Row {i+1}" for i in range(len(df_with_custom_index))]
    html_table = df_with_custom_index.to_html(index=True)
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
    df=pd.read_excel(r"data/testing_dataset.xlsx")
    id=random.randint(0,len(df))
    ques_temp=(df.loc[id])['question']
    ans_temp=(df.loc[id])['answer']
    return ques_temp,ans_temp

