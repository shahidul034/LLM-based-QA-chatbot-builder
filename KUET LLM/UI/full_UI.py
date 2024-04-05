import gradio as gr
import pandas as pd
import os
import random
from utils import display_table,current_time,random_ques_ans2
# from fine_tune_file.mistral_finetune import mistral_finetune
# from fine_tune_file.zepyhr_finetune import zepyhr_model
# from fine_tune_file.llama_finetune import llama_model
# from inference import ans_ret
###### Testing code
global cnt
cnt=1
data=[]
save_ques_ans=[]
cur_time=current_time()
def random_ques_ans(model_ans):
    df_temp=pd.read_excel(os.path.join("model_ans",str(model_ans)))
    global cnt
    id=int((df_temp.loc[cnt])['id'])
    ques_temp=(df_temp.loc[cnt])['question']
    ans_temp=(df_temp.loc[cnt])['answer']
    cnt+=1
    if cnt>=len(df_temp):
        cnt=0
        return ques_temp,ans_temp,id,0
    return ques_temp,ans_temp,id,1
def save_all(model_ans):
    temp=pd.DataFrame(data)
    temp.to_excel(f"score_report\\{model_ans+cur_time}.xlsx",index=False)
    gr.Info("Sucessfully save all the answer!!!")
def score_save(ques,ans,score,model_ans):
    data.append({
        "question":ques,
        'answer':ans,
        'rating':score
    })
    print('*'*10,":",data[len(data)-1])
    if len(data)%5==0:
        temp=pd.DataFrame(data)
        temp.to_excel(f"score_report\\{model_ans+cur_time}.xlsx",index=False)
        gr.Info("Sucessfully saved in local folder!!!")
    ques_temp,ans_temp,id,flag=random_ques_ans(model_ans)
    gr.Info("Your opinion is submitted successfully!!!")
    return gr.Label(value=id,label="ID"),gr.Label(value=ques_temp, label="Question"), gr.Label(value=ans_temp, label="Answer")
def new_ques(model_ans):
    ques_temp,ans_temp,id2,flag=random_ques_ans(model_ans)
    return {
        id:gr.Label(value=id2,label="ID"),
        ques:gr.Label(value=ques_temp,label="Question"),
        ans:gr.Label(value=ans_temp,label="Answer")
    }
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

#######

######Data collection
def save_the_ques(ques,ans):
    save_ques_ans.append({
        'question':ques,
        'ans':ans
    })
    if len(save_ques_ans)%3==0:
        temp=pd.DataFrame(save_ques_ans)
        temp.to_excel(f"save_ques_ans\\{cur_time}.xlsx",index=False)
        gr.Info("Sucessfully saved in local folder!!!")
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
                    lab=gr.Label(visible=False,value="You answer is submitted!!! Thank you for your contribution.",label="submitted")
                save.click(save_the_ques,[ques,ans],lab)
        
    with gr.Tab("Fine-tuning"):
        gr.Markdown(""" # Instructions: 
            1) Create a excel file in data folder and name it finetune_data.xlsx
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
            # exec(open('fine_tune_file\mistral_finetune.py').read())
            gr.Info("Finetune started!!!")
            # mistral_finetune()
            gr.Info("Finetune Ended!!!")
        def finetune_zepyhr():
            gr.Info("Finetune started!!!")
            # mistral_finetune()
            gr.Info("Finetune Ended!!!")
        def finetune_llama():
            gr.Info("Finetune started!!!")
            # mistral_finetune()
            gr.Info("Finetune Ended!!!")

        def edit_mis_fun():
            gr.Info("check \"fine_tune_file/mistral_finetune.py\" path for edit the source code and hyperparameter")
            os.system(r"fine_tune_file/mistral_finetune.py")
        def edit_zep_fun():
            gr.Info("check \"fine_tune_file/zepyhr_finetune.py\" path for edit the source code and hyperparameter")
            os.system(r"fine_tune_file/zepyhr_finetune.py")
        def edit_lla_fun():
            gr.Info("check \"fine_tune_file/llama_finetune.py\" path for edit the source code and hyperparameter")
            os.system(r"fine_tune_file/llama_finetune.py")
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
    with gr.Tab("Testing data generation"):
        def ans_gen_fun(model_name):
            import time
            progress=gr.Progress()
            idx=1
            model_ques_ans_gen=[]
            df_temp=pd.read_excel(r"data\testing_dataset.xlsx")
            for x in progress.tqdm(df_temp['question'], desc="Loading..."):
                time.sleep(0.1)
                model_ques_ans_gen.append({
                    "id":idx,
                    "question":x
                    ,'answer': "ready"
                    # ,'answer':ans_ret(x,model_name)
                })
                idx+=1
            pd.DataFrame(model_ques_ans_gen).to_excel(os.path.join("model_ans",f"_{model_name+cur_time}.xlsx"),index=False)
            gr.Info("Generating answer from model is finished!!! Now, it is ready for human evaluation.")
            return "Finished"

            
        gr.Markdown("""Please create a excel file and place the testing dataset data folder and name it \"testing_dataset.xlsx\"
                    This excel file has two columns: question, answer and id(answer and id are optional. id means unique number).
                    """)
        model_name=gr.Dropdown(choices=['Mistral','Zepyhr','Llama2'],label="Select the model")
        with gr.Row():
            ans_gen=gr.Button("Generate the answer of the testing dataset")
        with gr.Row():
            lab_test = gr.Label(label="Progess bar")
        ans_gen.click(ans_gen_fun,model_name,lab_test)

    with gr.Tab("Human evaluation"):
        def answer_updated(model_ans):
            df_ques_ans=pd.read_excel(os.path.join("model_ans",str(model_ans)))
            num=0
            print(df_ques_ans['id'][num],"**"*10)
            return [gr.Markdown(value=f"""# Model_name: {model_ans}
                               # Number of questions: {len(df_ques_ans)}""",visible=True),
                               gr.Label(value=str(df_ques_ans['id'][num])),
                               gr.Label(value=str(df_ques_ans['question'][num])),
                               gr.Label(value=str(df_ques_ans['answer'][num])),
                               gr.Dropdown(visible=False),
                               gr.Button(visible=False)
                               ]
        
        model_ans=gr.Dropdown(choices=os.listdir("model_ans"),label="Select the model answer for human evaluation")
        btn_1=gr.Button("submit")
        gr.Markdown(""" # Instructions: 
            In this section, humans evaluate the answers of the model given specific questions. Each answer is rated between 1 and 5 by anonymous students.
         """)
        lab_temp=gr.Markdown(visible=False)
        
        with gr.Row():
            id=gr.Label(value="",label="ID")
        with gr.Row():
            ques=gr.Label(value="",label="Question")
        with gr.Row():
            ans=gr.Label(value="",label="Answer")
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
        btn_1.click(answer_updated,model_ans,[lab_temp,id,ques,ans,model_ans,btn_1])
        btn.click(score_save, inputs=[ques,ans,score,model_ans], outputs=[id,ques,ans])
        question.click(new_ques,model_ans,[id,ques,ans])
        save_all_btn.click(save_all,model_ans,None)
        move_btn.click(move_to,[move,model_ans],[id,ques,ans])
    with gr.Tab("Inference"):
        def echo(message, history,model_name):
            gr.Info("Please wait!!! Model is loading!!")
            if model_name=="Mistral":
                # return ans_ret(message,model_name)
                return "mistral"
            elif model_name=="Zepyhr":
                # return ans_ret(message,model_name)
                return "Zepyhr"
            else:
                # return ans_ret(message,model_name)
                return "Llama2"
        
        model_name=gr.Dropdown(choices=['Mistral','Zepyhr','Llama2'],label="Select the model")
        gr.ChatInterface(fn=echo, additional_inputs=[model_name],examples=[["what is KUET?"],["Where is KUET located?"],['What do you like the most about KUET?']], title="KUET LLM")

demo.launch(share=False)