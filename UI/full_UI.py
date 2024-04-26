#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# rag_chain_ret,ans_ret, finetune#######
# search for on/off finetune,inference##
#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

import gradio as gr
import pandas as pd
import os
import random
from utils import display_table,current_time,random_ques_ans2,move_to,score_report_bar
#$$$$$$$$$$$$$$$$$
# from inference import ans_ret,rag_chain_ret,model_push
###### Testing code
global cnt
cnt=1
data=[]
save_ques_ans=[]
save_ques_ans_test=[]
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
    # if len(data)%5==0:
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
# Training question and answer saved
def save_the_ques(ques,ans):
    save_ques_ans.append({
        'question':ques,
        'ans':ans
    })
    if len(save_ques_ans)%3==0:
        temp=pd.DataFrame(save_ques_ans)
        temp.to_excel(f"save_ques_ans\\{cur_time}_trainData.xlsx",index=False)
        gr.Info("Sucessfully saved in local folder!!!")
    if len(os.listdir("save_ques_ans"))>=2:
        df_all=[]
        for x in os.listdir("save_ques_ans"):
            path=os.path.join("save_ques_ans",x)
            df_all.append(pd.read_excel(path))
        df_temp=pd.concat(df_all,axis=0)
        df_temp.to_excel("data//finetune_data.xlsx",index=False)

    return gr.Label(value="Submitted!! Generate new question",visible=True)
# Testing question and answer saved
def save_the_ques_test(ques,ans):
    print(ans)
    save_ques_ans_test.append({
        'question':ques,
        'ans':ans
    })
    # if len(save_ques_ans)%3==0:
    temp=pd.DataFrame(save_ques_ans_test)
    temp.to_excel(f"save_ques_ans_test\\{cur_time}_testData.xlsx",index=False)
    gr.Info("Sucessfully saved in local folder!!!")
    if len(os.listdir("save_ques_ans_test"))>=2:
        df_all=[]
        for x in os.listdir("save_ques_ans_test"):
            path=os.path.join("save_ques_ans_test",x)
            df_all.append(pd.read_excel(path))
        df_temp=pd.concat(df_all,axis=0)
        df_temp.to_excel("data//testing_dataset.xlsx",index=False)


def next_ques(ques,ans):
    ques_temp,ans_temp=random_ques_ans2()
    return gr.Label(value=ques_temp)
######
#***************************************************
with gr.Blocks() as demo:
    gr.Markdown("""
        # QA chatbot builder
            """)
    with gr.Tab("Data collection"):
            def parse_data_func(link_temp,num):
                    parse_data(link_temp,num)
                    gr.Info("Finished parsing!! Save as a docx file.")
            gr.Markdown(""" # Instructions: 
            In this page you can prepare data for finetuning and testing your model. The data can be provided through Excel file or directly via web interface.
                        
            ## 1. If you want to provide data in Excel file for model finetuning and testing.
            1) Create an Excel file in the data folder and name it finetune_data.xlsx for finetuning the model.
            2) Create an Excel file in the data folder and name it testing_data.xlsx for generating answers using the fine-tuned model.
            3) The Excel file has two columns: Prompt and Reply
            4) Prompt = question; Reply = answer to the question. The data format is shown below.
        """)
            gr.HTML(value=display_table())
            gr.Markdown("""
                    ## 2. You can use the below interface to create the dataset.
                 """)
            with gr.Tab("Training data generation"):
                with gr.Tab("Existing questions"):
                    gr.Markdown("""
                        After clicking the "save the answer" button. Those questions and answers are saved in the "data" folder as a finetune_data.xlsx file.
                    """)
                    ques_temp,ans_temp=random_ques_ans2()
                    with gr.Row():
                        ques=gr.Label(value=ques_temp,label="Question")
                    with gr.Row():
                        ans=gr.TextArea(label="Answer")
                    with gr.Row():
                        save=gr.Button("Save the answer")
                        question = gr.Button("Generate new question")
                    with gr.Row():
                        link_temp=gr.Textbox(label="Enter link for parse data",info="To provide the link for parsing the data from the website, this link can help create RAG data for the model.")
                        num=gr.Number(label="Number of links want to parse")
                        parse_data_btn=gr.Button("Parse data")
                    with gr.Row():
                        lab=gr.Label(visible=False,value="You ans is submitted!!! Thank you for your contribution.",label="submitted")
                    question.click(next_ques,None,ques)
                    save.click(save_the_ques,[ques,ans],lab)
                    from utils import parse_data
                    parse_data_btn.click(parse_data_func,[link_temp,num],None)
                with gr.Tab("Custom questions"):
                    gr.Markdown("""
                        After clicking the "save the answer" button. Those questions and answers are saved in the "data" folder as a finetune_data.xlsx file.
                    """)
                    with gr.Row():
                        ques=gr.Textbox(label="Question")
                    with gr.Row():
                        ans=gr.TextArea(label="Answer")
                    with gr.Row():
                        save=gr.Button("Save the answer")
                    with gr.Row():
                        lab=gr.Label(visible=False,value="You answer is submitted!!! Thank you for your contribution.",label="submitted")
                    save.click(save_the_ques,[ques,ans],lab)
            with gr.Tab("Testing data generation"):
                gr.Markdown("""
                    You can create test data for generating answers using the Finetune model, which will be used for testing the model's performance. 
                    After clicking the "save the answer" button. Those questions and answers are saved in the "data" folder as a testing_data.xlsx file. You can ignore the "Answer" textbox. If you do not want to give the answer.
                            """)
                with gr.Row():
                    ques=gr.Textbox(label="Question")
                with gr.Row():
                    ans=gr.TextArea(label="Answer",placeholder="(optional) Although the answer is optional it will help users during model evaluation.")
                with gr.Row():
                    save_test=gr.Button("Save the answer")
                with gr.Row():
                    lab=gr.Label(visible=False,value="You answer is submitted!!! Thank you for your contribution.",label="submitted")
                save_test.click(save_the_ques_test,[ques,ans],None)
                

#***************************************************      
    with gr.Tab("Fine-tuning"):
        
        gr.Markdown("""
            # Instructions:
            1) Required VRAM for training: 24GB, for inference: 16GB.\n
            2) For fine-tuning a custom model select 'custom modele' option in 'Select the model for fine-tuning' dropdown section. The custom model can be configured by editing the code section.\n
            3) After fine-tuning the model, it will be saved in the "models" folder.
        """)
            
        def edit_model_parameter(model_name_temp,edit_code,code_temp,lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout):
            # write code to files if code was edited
            if edit_code:
                if model_name_temp=="Mistral":
                    open(r"fine_tune_file/mistral_finetune.py","w").write(code_temp)
                elif model_name_temp=="Zephyr":
                    open(r"fine_tune_file/zepyhr_finetune.py","w").write(code_temp)
                elif model_name_temp=="Llama":
                    open(r"fine_tune_file/llama_finetune.py","w").write(code_temp)
            # importing just before finetuning, to ensure the latest code is used
            from fine_tune_file.mistral_finetune import mistral_tainer
            from fine_tune_file.zepyhr_finetune import zephyr_trainer
            from fine_tune_file.llama_finetune import llama_trainer
            from fine_tune_file.finetune_file import custom_model_trainer
            # create instance of the finetuning classes and then call the finetune function
            if model_name_temp=="Mistral":
                gr.Info("Finetune started!!!")
                trainer = mistral_tainer()
                trainer.mistral_finetune(lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout)
                gr.Info("Finetune Ended!!!")
            elif model_name_temp=="Zephyr":
                gr.Info("Finetune started!!!")
                trainer = zephyr_trainer()
                trainer.zepyhr_model(lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout)
                gr.Info("Finetune Ended!!!")
            elif model_name=="Llama":
                gr.Info("Finetune started!!!")
                trainer = llama_trainer()
                trainer.llama_model(lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout)
                gr.Info("Finetune Ended!!!")
            else:
                trainer=custom_model_trainer()
                trainer.custom_model_trainer()
        
        def code_show(model_name):
            if model_name=="Mistral":
                f=open(r"fine_tune_file/mistral_finetune.py").read()
                return gr.Code(visible=True,value=f,interactive=True,language="python")
            elif model_name=="Zephyr":
                f=open(r"fine_tune_file/zepyhr_finetune.py").read()
                return gr.Code(visible=True,value=f,interactive=True,language="python")
            elif model_name=="Llama":
                f=open(r"fine_tune_file/llama_finetune.py").read()
                return gr.Code(visible=True,value=f,interactive=True,language="python")

        def custom_model(model_name):
            if model_name=="custom model":
                f=open(r"fine_tune_file/finetune_file.py").read()
                return [gr.Code(visible=True,value=f,interactive=True,language="python"),gr.Button(visible=False)]
            else:
                return gr.Code(visible=False)

        def change_code_fun(code_,model_name):
            if model_name=="Mistral":
                open(r"fine_tune_file/mistral_finetune.py","w").write(code_)
                gr.Info("Successfully saved code!!!")
            elif model_name=="Zephyr":
                open(r"fine_tune_file/zepyhr_finetune.py","w").write(code_)
                gr.Info("Successfully saved code!!!")
            elif model_name=="Llama":
                open(r"fine_tune_file/llama_finetune.py","w").write(code_)
                gr.Info("Successfully saved code!!!")

        with gr.Row():
            code_temp=gr.Code(visible=False)
        with gr.Row():
            model_name=gr.Dropdown(choices=["Mistral","Zephyr","Llama","custom model"],label="Select the model for fine-tuning")        

        with gr.Accordion("Parameter setup"):
            with gr.Row():
                lr=gr.Number(label="Learning rate",value=5e-6,interactive=True,info="The step size at which the model parameters are updated during training. It controls the magnitude of the updates to the model's weights.")
                epoch=gr.Textbox(label="Epochs",value=2,interactive=True,info="One complete pass through the entire training dataset during the training process. It's a measure of how many times the algorithm has seen the entire dataset.")
                batch_size=gr.Textbox(label="Batch size",value=4,interactive=True,info="The number of training examples used in one iteration of training. It affects the speed and stability of the training process.")
                gradient_accumulation = gr.Textbox(info="Gradient accumulation involves updating model weights after accumulating gradients over multiple batches, instead of after each individual batch.",label="gradient_accumulation",value=4,interactive=True)
            with gr.Row():
                quantization = gr.Dropdown(info="Quantization is a technique used to reduce the precision of numerical values, typically from 32-bit floating-point numbers to lower bit representations.",label="quantization",choices=[4,8],value=8,interactive=True)
                lora_r = gr.Textbox(info="LoRA_r is a hyperparameter associated with the rank of the low-rank approximation used in LoRA.",label="lora_r",value=16,interactive=True)
                lora_alpha = gr.Textbox(info="LoRA_alpha is a hyperparameter used in LoRA for controlling the strength of the adaptation.",label="lora_alpha",value=32,interactive=True)
                lora_dropout = gr.Textbox(info="LoRA_dropout is a hyperparameter used in LoRA to control the dropout rate during fine-tuning.",label="lora_dropout",value=.05,interactive=True)
        with gr.Row():
            edit_code=gr.Button("Advance code editing")
        with gr.Row():
            code_temp=gr.Code(visible=False)
        with gr.Row():
            parameter_alter=gr.Button("Finetune")
        edit_code.click(code_show,model_name,code_temp)
        parameter_alter.click(edit_model_parameter,[model_name,edit_code,code_temp,lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout],None)
        model_name.change(custom_model,model_name,[code_temp,edit_code])
        
#***************************************************
    with gr.Tab("Testing data generation from model"):
        def ans_gen_fun(model_name):
            import time
            progress=gr.Progress()
            idx=1
            model_ques_ans_gen=[]
            df_temp=pd.read_excel(r"data/testing_dataset.xlsx")
            #$$$$$$$$$$$$$$$$$
            # rag_chain=rag_chain_ret(model_name)
            for x in progress.tqdm(df_temp['question'], desc="Loading..."):
                # time.sleep(0.1)
                model_ques_ans_gen.append({
                    "id":idx,
                    "question":x
                    ,'answer': "ready"
                    #$$$$$$$$$$$$$$$$$
                    # ,'answer':ans_ret(x,rag_chain)
                })
                idx+=1
            pd.DataFrame(model_ques_ans_gen).to_excel(os.path.join("model_ans",f"_{model_name+cur_time}.xlsx"),index=False)
        gr.Info("Generating answer from model is finished!!! Now, it is ready for human evaluation.")
               
        gr.Markdown("""Provide an Excel file named \"testing_dataset.xlsx\ in data folder"
                        This excel file has two columns: question, answer (answer is optional).
                        """)
        model_name=gr.Dropdown(choices=os.listdir("models"),label="Select the model")
        with gr.Row():
            ans_gen=gr.Button("Generate the answer of the testing dataset")
        ans_gen.click(ans_gen_fun,model_name,None)
#***************************************************
    def bar_plot_fn():
        temp=score_report_bar()
        return gr.BarPlot(
            temp,
            x="Model Name",
            y="Average Rating",
            x_title="Model name",
            y_title="Average Rating",
            title="Model performance",
            tooltip=["Model Name", "Average Rating"],
            y_lim=[1, 100],
            width=150,
            # height=1000,
            visible=True
        )
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
            Those values are saved in the "scrore_report" folder. 
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
            human_ans_btn=gr.Button("show answer from other users")
        with gr.Row():
            human_ans_lab=gr.Label(label="Human answer",visible=False)   
        with gr.Row():
            btn = gr.Button("Save")
            question = gr.Button("Generate new question")
        # with gr.Row():
            # save_all_btn=gr.Button("Save all the data in dataframe")
        with gr.Row():
            move=gr.Number(label="Move to the question")
            move_btn=gr.Button("move")
        with gr.Row():
            btn_plot=gr.Button("Plot generation")
        with gr.Row():
            plot = gr.BarPlot(visible=False)
        btn_plot.click(bar_plot_fn, None, outputs=plot)
        btn_1.click(answer_updated,model_ans,[lab_temp,id,ques,ans,model_ans,btn_1])
        btn.click(score_save, inputs=[ques,ans,score,model_ans], outputs=[id,ques,ans])
        question.click(new_ques,model_ans,[id,ques,ans])
        # save_all_btn.click(save_all,model_ans,None)
        move_btn.click(move_to,[move,model_ans],[id,ques,ans])
        def human_ans_func(id, ques):
            df_hum=pd.read_excel(r"data\testing_dataset.xlsx")
            temp=[]
            for x,y in zip(df_hum['question'],df_hum['answer']):
                if x==ques:
                   temp.append(y)
            if len(temp)==0:
                temp=["This question's answer is not available."]
            return [gr.Button("Show answer from other users"),gr.Label(value="\n".join(temp),visible=True)] 
        human_ans_btn.click(human_ans_func,[id, ques],[human_ans_btn,human_ans_lab])
#***************************************************    
    with gr.Tab("Inference"):
        def echo(message, history,model_name):
            gr.Info("Please wait!!! Model is loading!!")
            #$$$$$$$$$$$$$$$$$
            # rag_chain=rag_chain_ret()
            if model_name=="Mistral":
                #$$$$$$$$$$$$$$$$$
                # return ans_ret(message,rag_chain)
                return """Khulna University of Engineering & Technology (KUET) is located in Fulbarigate, Teligati, Khulna, Bangladesh. The expansive campus covers an area of 101 acres. KUET is a prestigious educational institution renowned for its quality education and research in engineering."""
            elif model_name=="Zepyhr":
                #$$$$$$$$$$$$$$$$$
                # return ans_ret(message,rag_chain)
                return "Zepyhr"
            elif model_name=="Llama2":
                #$$$$$$$$$$$$$$$$$
                # return ans_ret(message,rag_chain)
                return "Llama"
        
        model_name=gr.Dropdown(choices=os.listdir("models"),label="Select the model")
        gr.ChatInterface(fn=echo, additional_inputs=[model_name], title="Chatbot")
    with gr.Tab("Deployment"):
        gr.Markdown("""\"deploy\" folder has all the code for the deployment of the model.""")
        def deploy_func(model_name):
            f=open("deploy//info.txt","w")
            f.write(f"{model_name}")

            
        model_name=gr.Dropdown(choices=os.listdir("models"),label="Select the model")
        btn_model=gr.Button("Deploy")
        btn_model.click(deploy_func,model_name)

demo.launch(share=True)