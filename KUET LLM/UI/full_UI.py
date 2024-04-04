import gradio as gr
import pandas as pd
import os
from utils import display_table,file_df,random_ques_ans2
###### Testing code
global cnt
cnt=0
data=[]
save_ques_ans=[]
df,file_name,ff,cur_time=file_df()
def random_ques_ans():
    import random
    # id=random.randint(0,len(df)-1)
    global cnt
    id=int((df.loc[cnt])['id'])
    ques_temp=(df.loc[cnt])['question']
    ans_temp=(df.loc[cnt])['answer']
    cnt+=1
    if cnt>=len(df):
        cnt=0
        return ques_temp,ans_temp,id,0
    return ques_temp,ans_temp,id,1
def save_all():
    temp=pd.DataFrame(data)
    temp.to_excel(f"score_report\\{file_name}.xlsx",index=False)
    gr.Info("Sucessfully save all the answer!!!")
def score_save(ques,ans,score):
    data.append({
        "question":ques,
        'answer':ans,
        'rating':score
    })
    print('*'*10,":",data[len(data)-1])
    if len(data)%5==0:
        temp=pd.DataFrame(data)
        temp.to_excel(f"score_report\\{file_name}.xlsx",index=False)
    ques_temp,ans_temp,id,flag=random_ques_ans()
    gr.Info("Your opinion is submitted successfully!!!")
    return gr.Label(value=id,label="ID"),gr.Label(value=ques_temp, label="Question"), gr.Label(value=ans_temp, label="Answer")
def new_ques():
    ques_temp,ans_temp,id2,flag=random_ques_ans()
    return {
        id:gr.Label(value=id2,label="ID"),
        ques:gr.Label(value=ques_temp,label="Question"),
        ans:gr.Label(value=ans_temp,label="Answer")
    }
def move_to(move):
    if int(move)>=len(df)+1:
        gr.Info(f"Number of questions: {len(df)}")
        move=0
    id_temp=(df.loc[move-1])['id']   
    ques_temp=(df.loc[move-1])['question']
    ans_temp=(df.loc[move-1])['answer']
    return [
        gr.Label(value=str(id_temp),label="ID"),
        gr.Label(value=ques_temp,label="Question"),
        gr.Label(value=ans_temp,label="Answer")
    ]

#######

######Data collection
def save_the_ques(ques,ans):
    save_ques_ans.append({
        'question':ques,
        'ans':ans
    })
    if len(save_ques_ans)%3==0:
        temp=pd.DataFrame(save_ques_ans)
        temp.to_excel(f"save_data\\{cur_time}.xlsx",index=False)
    return gr.Label(value="Submitted!! Generate new question",visible=True)

def next_ques(ques,ans):
    ques_temp,ans_temp=random_ques_ans2()
    return gr.Label(value=ques_temp)
######

with gr.Blocks() as demo:
    with gr.Tab("Data collection"):
            with gr.Tab("Existing questions"):
                ques_temp,ans_temp=random_ques_ans2()
                with gr.Row():
                    ques=gr.Label(value=ques_temp,label="Question")
                with gr.Row():
                    ans=gr.TextArea(label="Answer")
                with gr.Row():
                    save=gr.Button("Save the answer")
                    question = gr.Button("Generate new question")
                with gr.Row():
                    lab=gr.Label(visible=False,value="You ans is submitted!!! Thank you for your contribution.",label="submitted")
                question.click(next_ques,None,ques)
                save.click(save_the_ques,[ques,ans],lab)
            with gr.Tab("Custom questions"):
                with gr.Row():
                    ques=gr.Textbox(label="Question")
                with gr.Row():
                    ans=gr.TextArea(label="Answer")
                with gr.Row():
                    save=gr.Button("Save the answer")
                with gr.Row():
                    lab=gr.Label(visible=False,value="You ans is submitted!!! Thank you for your contribution.",label="submitted")
                save.click(save_the_ques,[ques,ans],lab)
        
    with gr.Tab("Fine-tuning"):
        gr.Markdown(""" # Instructions: 
            1) Create a excel file in data folder and name it data.xlsx
            2) This excel file has two column: Prompt and Reply
            3) Prompt = Question; Reply = answer of the question. Data format is shown in below.
        """)
        gr.HTML(value=display_table())
        gr.Markdown("""
            4) Need 24GB VRAM for training and 16 GB VRAM for inference
            5) Click the model name for finetuning
            6) You can change the hyper parameter using edit button
        """)
        def finetune_mistral():
            exec(open('fine_tune_file\mistral_finetune.py').read())
        def finetune_zepyhr():
            exec(open('fine_tune_file\zepyhr_finetune.py').read())
        def finetune_llama():
            exec(open('fine_tune_file\llama_finetune.py').read())

        def edit_mis_fun():
            os.system(r"fine_tune_file\mistral_finetune.py")
        def edit_zep_fun():
            os.system(r"fine_tune_file\zepyhr_finetune.py")
        def edit_lla_fun():
            os.system(r"fine_tune_file\llama_finetune.py")
        with gr.Row():
            mistral_btn=gr.Button("mistralai/Mistral-7B-Instruct-v0.2")
            edit_mis=gr.Button("Edit Mistral hyper-parameter")
        with gr.Row():
            zepyhr_btn=gr.Button("HuggingFaceH4/zephyr-7b-beta")
            edit_zep=gr.Button("Edit Zepyhr hyper-parameter")
        with gr.Row():
            llama_btn=gr.Button("NousResearch/Llama-2-7b-chat-hf")
            edit_lla=gr.Button("Edit Llama hyper-parameter")
        edit_mis.click(edit_mis_fun)
        edit_zep.click(edit_zep_fun)
        edit_lla.click(edit_lla_fun)

        mistral_btn.click(finetune_mistral)
        zepyhr_btn.click(finetune_zepyhr)
        llama_btn.click(finetune_llama)

    with gr.Tab("Human evaluation"):
        gr.Markdown(""" # Instructions: 
            In this section, humans evaluate the answers of the model given specific questions. Each answer is rated between 1 and 5 by anonymous students.
         """)
        ques_temp,ans_temp,id_temp,flag=random_ques_ans()
        gr.Markdown(
        f"""
        # Model name: {ff}
        # No. of questions:{len(df)} 
        """)
        with gr.Row():
            id=gr.Label(value=id_temp,label="ID")
        with gr.Row():
            ques=gr.Label(value=ques_temp,label="Question")
        with gr.Row():
            ans=gr.Label(value=ans_temp,label="Answer")
        with gr.Row():
            score = gr.Radio(choices=[1,2,3,4,5],label="Rating")
        with gr.Row():
            btn = gr.Button("Save")
            question = gr.Button("Generate new question")
        with gr.Row():
            save_all_btn=gr.Button("Save all the data in dataframe")
        with gr.Row():
            move=gr.Number(label="Move to the question")
            move_btn=gr.Button("move")
        
        btn.click(score_save, inputs=[ques,ans,score], outputs=[id,ques,ans])
        question.click(new_ques,None,[id,ques,ans])
        save_all_btn.click(save_all,None,None)
        move_btn.click(move_to,move,[id,ques,ans])
    with gr.Tab("Inference"):
        def echo(message, history,model_name):
            return model_name
        
        model_name=gr.Dropdown(choices=['a','b','c'],label="Select the model")
        gr.ChatInterface(fn=echo, additional_inputs=[model_name], title="KUET LLM")

demo.launch(share=False)