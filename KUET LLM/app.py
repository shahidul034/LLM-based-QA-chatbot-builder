import pandas as pd
df=pd.read_excel("excel file\model_ans2.xlsx")
global cnt
cnt=0
data=[]
import datetime
current_datetime = datetime.datetime.now()
file_name = current_datetime.strftime("%Y_%m_%d_%H_%M_%S")
def random_ques_ans():
    # import random
    # id=random.randint(0,59)
    global cnt
    ques_temp=(df.loc[cnt])['question']
    ans_temp=(df.loc[cnt])['answer']
    cnt+=1
    if cnt==len(df):
        cnt=0
    return ques_temp,ans_temp
def score_save(ques,ans,score):
    data.append({
        "question":ques,
        'answer':ans,
        'rating':score
    })
    if len(data)%10==0:
        temp=pd.DataFrame(data)
        temp.to_excel(f"score_report//{file_name}.xlsx",index=False)
    ques_temp,ans_temp=random_ques_ans()
    gr.Info("Your opinion is submitted successfully!!!")
    return gr.Label(value=ques_temp, label="Question"), gr.Label(value=ans_temp, label="Answer")
def new_ques():
    ques_temp,ans_temp=random_ques_ans()
    return {
        ques:gr.Label(value=ques_temp,label="Question"),
        ans:gr.Label(value=ans_temp,label="Answer")
    }
import gradio as gr
import pandas as pd
css = """
#accepted {background-color: green;align-content: center;font: 30px Arial, sans-serif;}
#wrong {background-color: red;align-content: center;font: 30px Arial, sans-serif;}
#already {background-color: blue;align-content: center;font: 30px Arial, sans-serif;}
"""
ques_temp,ans_temp=random_ques_ans()
with gr.Blocks(css=css) as demo:
    with gr.Row():
        ques=gr.Label(value=ques_temp,label="Question")
    with gr.Row():
        ans=gr.Label(value=ans_temp,label="Answer")
    with gr.Row():
        # correct = gr.Button("Correct")
        # wrong = gr.Button("Wrong")
        score = gr.Radio(choices=[1,2,3,4,5],label="Rating")
    with gr.Row():
        btn = gr.Button("Save")
        question = gr.Button("Generate new question")
    # correct.click(correct_cnt,[ques,ans],[ques,ans])
    # wrong.click(wrong_cnt,[ques,ans],[ques,ans])
    
    btn.click(score_save, inputs=[ques,ans,score], outputs=[ques,ans])
    question.click(new_ques,None,[ques,ans])

demo.launch(share=False)