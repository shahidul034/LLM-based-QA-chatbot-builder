#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
# rag_chain_ret,ans_ret, finetune#######
# search for on/off finetune,inference##
#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

import gradio as gr
import pandas as pd
import os
from pathlib import Path
import random
from utils import display_table,current_time,random_ques_ans2,move_to,score_report_bar,all_contri_ans
from inference import model_chain
import warnings
warnings.filterwarnings('ignore')
#$$$$$$$$$$$$$$$$$
# from inference import rag_chain_ret
###### Testing code
os.environ["WANDB_DISABLED"] = "true"
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
def score_save(ques,ans,score,model_ans,token_key):
    data.append({
        "question":ques,
        'answer':ans,
        'rating':score
    })
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
# def move_to(move,model_ans):
#     df_temp=pd.read_excel(os.path.join("model_ans",str(model_ans)))
#     id_temp=int((df_temp.loc[move])['id'])
#     ques_temp=(df_temp.loc[move])['question']
#     ans_temp=(df_temp.loc[move])['answer']
#     if int(move)>=len(df_temp)+1:
#         gr.Info(f"Number of questions: {len(df_temp)}")
#         move=0
#     return [
#         gr.Label(value=str(id_temp),label="ID"),
#         gr.Label(value=ques_temp,label="Question"),
#         gr.Label(value=ans_temp,label="Answer")
#     ]

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
        if Path("data//finetune_data.xlsx").is_file():
            df_all.append(pd.read_excel("data//finetune_data.xlsx"))
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
    with gr.Tab("Data Collection"):
            def parse_data_func(link_temp,progress=gr.Progress()):
                    progress(0, desc="Starting...")
                    parse_data(link_temp,progress)
                    gr.Info("Finished parsing!! Save as a docx file.")
            gr.Markdown(""" # Instructions: 
            In this page you can prepare data for finetuning and testing your model. The data can be provided through Excel file or directly via web interface. Additionally, data can be parsed from the target website(Data parsing for RAG) to further enhance the model performance.  
                        
            ## 1. If you want to provide data in Excel file or CSV file for model finetuning and testing.
            1) Create an Excel or CSV file in the data folder and name it "finetune_data.xlsx" for finetuning the model.
            2) Create an Excel file or CSV file in the data folder and name it "testing_data.xlsx" for generating answers using the fine-tuned model.
            3) "finetune_data.xlsx" has two columns: question and answer. "testing_data.xlsx" has four columns: question, contexts, ground_truths. 
        """)
            gr.Markdown("""
                    ## finetune_data.xlsx
                 """)
            gr.HTML(value=display_table(), label="finetune_data.xlsx")
            gr.Markdown("""
                    ## testing_data.xlsx
                 """)
            gr.HTML(value=display_table(r"data\testing_dataset.xlsx"), label="testing_data.xlsx")
            gr.Markdown("""
                    ## 2. You can use the below interface to create the dataset for training and testing models.
                 """)
            with gr.Tab("Training Data Generation"):
                with gr.Tab("Existing Questions"):
                    gr.Markdown("""
                        Existing questions are provided by the administrator and placed in the data folder named "existing_dataset.xlsx". This file has only one column: "question".
                        After clicking the "Save the Answer" button. Those questions and answers are saved in the "data" folder as a finetune_data.xlsx file.
                    """)
                    ques_temp,ans_temp=random_ques_ans2()
                    with gr.Row():
                        ques=gr.Label(value=ques_temp,label="Question")
                    with gr.Row():
                        ans=gr.TextArea(label="Answer")
                    with gr.Row():
                        save=gr.Button("Save the Answer")
                        question = gr.Button("Generate New Question")
                    with gr.Row():
                        lab=gr.Label(visible=False,value="You ans is submitted!!! Thank you for your contribution.",label="Submitted")
                    question.click(next_ques,None,ques)
                    save.click(save_the_ques,[ques,ans],lab)
                    
                with gr.Tab("Custom Questions"):
                    gr.Markdown("""
                        After clicking the "save the answer" button. Those questions and answers are saved in the "data" folder as a finetune_data.xlsx file.
                    """)
                    with gr.Row():
                        ques=gr.Textbox(label="Question")
                    with gr.Row():
                        ans=gr.TextArea(label="Answer")
                    with gr.Row():
                        save=gr.Button("Save the Answer")
                    with gr.Row():
                        lab=gr.Label(visible=False,value="You answer is submitted!!! Thank you for your contribution.",label="Submitted")
                    save.click(save_the_ques,[ques,ans],lab)
            with gr.Tab("Testing Data Generation"):
                gr.Markdown("""
                    You can create test data for generating answers using the fine-tune model, which will be used for testing the model's performance. 
                    After clicking the "Save the Answer" button. Those questions and answers are saved in the "data" folder as a testing_data.xlsx file. You can ignore the "Answer" textbox. If you do not want to give the answer.
                            """)
                with gr.Row():
                    ques=gr.Textbox(label="Question")
                with gr.Row():
                    ans=gr.TextArea(label="Ground Truth")
                with gr.Row():
                    ans=gr.TextArea(label="Contexts")
                with gr.Row():
                    save_test=gr.Button("Save the Answer")
                with gr.Row():
                    lab=gr.Label(visible=False,value="You answer is submitted!!! Thank you for your contribution.",label="Submitted")
                save_test.click(save_the_ques_test,[ques,ans],None)
            with gr.Row():
                gr.Markdown("""
                        ## 3. Data parsing for RAG
                    """)
            with gr.Row():    
                link_temp=gr.Textbox(label="Enter Link to Parse Data for RAG",info="To provide the link for parsing the data from the website, this link can help create RAG data for the model.")
                parse_data_btn=gr.Button("Parse Data")
            from utils import parse_data
            parse_data_btn.click(parse_data_func,link_temp,link_temp)

#***************************************************      
    with gr.Tab("Fine-tuning"):
        
        gr.Markdown("""
            # Instructions:
            1) Required VRAM for training: 24GB, for inference: 16GB.(Mistral, Zepyhr and Lllama)\n
            2) Required VRAM for training: 5GB, for inference: 4GB.(Phi,Flan-T5)
            3) For fine-tuning a custom model select 'custom model' option in 'Select the model for fine-tuning' dropdown section. The custom model can be configured by editing the code section.\n
            4) After fine-tuning the model, it will be saved in the "models" folder.
        """)
            
        def edit_model_parameter(model_name_temp,edit_code,code_temp,lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout, progress=gr.Progress()):
            progress(0, desc="Fine-tune started!! please wait ...")
            # write code to files if code was edited
            if edit_code and len(code_temp)!=0:
                if model_name_temp=="Mistral":
                    open(r"fine_tune_file/mistral_finetune.py","w").write(code_temp)
                elif model_name_temp=="Zephyr":
                    open(r"fine_tune_file/zepyhr_finetune.py","w").write(code_temp)
                elif model_name_temp=="Llama":
                    open(r"fine_tune_file/llama_finetune.py","w").write(code_temp)
                elif model_name_temp=="Phi":
                    open(r"fine_tune_file/phi_finetune.py","w").write(code_temp)
                elif model_name_temp=="Custom model":
                    open(r"fine_tune_file/finetune_file.py","w").write(code_temp)
            # importing just before finetuning, to ensure the latest code is used
            # from fine_tune_file.mistral_finetune import mistral_trainer
            # from fine_tune_file.zepyhr_finetune import zephyr_trainer
            # from fine_tune_file.llama_finetune import llama_trainer
            # from fine_tune_file.phi_finetune import phi_trainer
            from fine_tune_file.finetune_file import custom_model_trainer
            # from fine_tune_file.flant5_finetune import flant5_trainer
            from fine_tune_file.modular_finetune import get_trainer
            # create instance of the finetuning classes and then call the finetune function
            if model_name_temp=="Mistral":
                gr.Info("Fine-tune started!!!")
                trainer=get_trainer("mistral")
                # trainer = mistral_trainer()
                trainer.mistral_finetune(lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout)
                gr.Info("Fine-tune Ended!!!")
            elif model_name_temp=="Zephyr":
                gr.Info("Fine-tune started!!!")
                trainer=get_trainer("zephyr")
                # trainer = zephyr_trainer()
                trainer.zepyhr_finetune(lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout)
                gr.Info("Fine-tune Ended!!!")
            elif model_name_temp=="Llama":
                gr.Info("Fine-tune started!!!")
                trainer=get_trainer("llama")
                # trainer = llama_trainer()
                trainer.llama_finetune(lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout)
                gr.Info("Fine-tune Ended!!!")
            elif model_name_temp=="Phi":
                gr.Info("Fine-tune started!!!")
                # trainer = phi_trainer()
                trainer=get_trainer("phi")
                trainer.phi_finetune(lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout)
                gr.Info("Fine-tune Ended!!!")
            elif model_name_temp=="Flan-T5":
                gr.Info("Fine-tune started!!!")
                # trainer = flant5_trainer()
                trainer=get_trainer("flan-T5")
                trainer.flant5_finetune(lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout)
                gr.Info("Fine-tune Ended!!!")
            elif model_name_temp=="Custom model":
                gr.Info("Fine-tune started!!!")
                trainer=custom_model_trainer()
                trainer.custom_model_finetune()
                gr.Info("Fine-tune Ended!!!")
        
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
            elif model_name=="Phi":
                f=open(r"fine_tune_file/phi_finetune.py").read()
                return gr.Code(visible=True,value=f,interactive=True,language="python")
            elif model_name=="Flan-T5":
                f=open(r"fine_tune_file/flant5_finetune.py").read()
                return gr.Code(visible=True,value=f,interactive=True,language="python")

        def custom_model(model_name): # It shows custom model code in the UI.
            if model_name=="Custom model":
                f=open(r"fine_tune_file/finetune_file.py").read()
                return [gr.Code(visible=True,value=f,interactive=True,language="python"),gr.Button(visible=False)]
            else:
                return [gr.Code(visible=False),gr.Button("Advance Code Editing",visible=True)]
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
            elif model_name=="Phi":
                open(r"fine_tune_file/phi_finetune.py","w").write(code_)
                gr.Info("Successfully saved code!!!")
            elif model_name=="Flan-T5":
                open(r"fine_tune_file/flant5_finetune.py","w").write(code_)
                gr.Info("Successfully saved code!!!")

        def finetune_emb(emb_name):
            from embedding_finetune import train_model_with_custom_dataset
            gr.Info("Embedding fine-tune is started!!!")
            train_model_with_custom_dataset("emb_data.xlsx",emb_name)

        with gr.Row():
            code_temp=gr.Code(visible=False)
        with gr.Row():
            embedding_model=gr.Dropdown(choices=["BAAI/bge-base-en-v1.5","dunzhang/stella_en_1.5B_v5","dunzhang/stella_en_400M_v5","nvidia/NV-Embed-v2","Alibaba-NLP/gte-Qwen2-1.5B-instruct"],label="Select the embedding model for fine-tuning")        
            btn_emb=gr.Button("Fine-tune the embedding model")        
        with gr.Row():
            model_name=gr.Dropdown(choices=["Mistral","Zephyr","Llama","Phi","Flan-T5","Custom model"],label="Select the LLM for fine-tuning")        
        with gr.Accordion("Parameter Setup"):
            with gr.Row():
                lr=gr.Number(label="learning_rate",value=5e-6,interactive=True,info="The step size at which the model parameters are updated during training. It controls the magnitude of the updates to the model's weights.")
                epoch=gr.Number(label="epochs",value=2,interactive=True,info="One complete pass through the entire training dataset during the training process. It's a measure of how many times the algorithm has seen the entire dataset.")
                batch_size=gr.Number(label="batch_size",value=4,interactive=True,info="The number of training examples used in one iteration of training. It affects the speed and stability of the training process.")
                gradient_accumulation = gr.Number(info="Gradient accumulation involves updating model weights after accumulating gradients over multiple batches, instead of after each individual batch.",label="gradient_accumulation",value=4,interactive=True)
            with gr.Row():
                quantization = gr.Dropdown(info="Quantization is a technique used to reduce the precision of numerical values, typically from 32-bit floating-point numbers to lower bit representations.",label="quantization",choices=[4,8],value=8,interactive=True)
                lora_r = gr.Number(info="LoRA_r is a hyperparameter associated with the rank of the low-rank approximation used in LoRA.",label="lora_r",value=16,interactive=True)
                lora_alpha = gr.Number(info="LoRA_alpha is a hyperparameter used in LoRA for controlling the strength of the adaptation.",label="lora_alpha",value=32,interactive=True)
                lora_dropout = gr.Number(info="LoRA_dropout is a hyperparameter used in LoRA to control the dropout rate during fine-tuning.",label="lora_dropout",value=.05,interactive=True)
        with gr.Row():
            edit_code=gr.Button("Advance Code Editing")
        with gr.Row():
            code_temp=gr.Code(visible=False)
        with gr.Row():
            parameter_alter=gr.Button("Fine-tune")
        with gr.Row():
            fin_com=gr.Label(visible=False)
        edit_code.click(code_show,model_name,code_temp)
        # On click finetune button 
        parameter_alter.click(edit_model_parameter,[model_name,edit_code,code_temp,lr,epoch,batch_size,gradient_accumulation,quantization,lora_r,lora_alpha,lora_dropout],model_name)
        model_name.change(custom_model,model_name,[code_temp,edit_code])
        btn_emb.click(finetune_emb,[embedding_model], None)
#***************************************************
    with gr.Tab("Testing Data Generation from Model"):
        def ans_gen_fun(model_name,progress=gr.Progress()):
            if not os.path.exists(r"data\testing_dataset.xlsx"):
                gr.Warning("You need to create testing dataset first from Data collection.")
                return
            import time
            from model_ret import calculate_rag_metrics
            progress(0, desc="Starting...")
            idx=1
            model_ques_ans_gen=[]
            df_temp=pd.read_excel(r"data/testing_dataset.xlsx")
            #$$$$$$$$$$$$$$$$$
            infer_model = model_chain(model_name)
            rag_chain=infer_model.rag_chain_ret()
            for x in progress.tqdm(df_temp.values):
                # time.sleep(0.1)
                model_ques_ans_gen.append({
                    "id":idx,
                    "question":x[0]
                    ,'answer':rag_chain.ans_ret(x,rag_chain)
                    , "contexts":x[2]
                    , "ground_truths":x[1]
                })
                idx+=1
            temp=calculate_rag_metrics(model_ques_ans_gen,model_name)
            pd.DataFrame(temp).to_excel(os.path.join("model_ans",f"_{model_name+cur_time}.xlsx"),index=False)
        gr.Info("Generating answer from model is finished!!! Now, it is ready for human evaluation. Model answer is saved in \"model_ans\" folder. ")
               
        gr.Markdown(""" # Instructions:\n
                    In this page you can generate answer from fine-tuned models for human evaluation. The questions must be created using 'Testing data generation' section of 'Data collection' tab.
                    Here, we include RAGAS for evaluating RAG (answer_correctness, answer_similarity, answer_relevancy, faithfulness, context_recall,context_precision).     
                    """)
        model_name=gr.Dropdown(choices=os.listdir("models"),label="Select the Model")
        with gr.Row():
            ans_gen=gr.Button("Generate the Answer of the Testing Dataset")
        ans_gen.click(ans_gen_fun,model_name,model_name)
#***************************************************Human evaluation
    import secrets

    def generate_token():
        while True:
            token=secrets.token_hex(6)
            f=[x[:-5] for x in os.listdir("save_ques_ans")]
            if token not in f:
                data = {
                        'id': [],
                        'question': [],
                        'answer': []
                    }
                df = pd.DataFrame(data)
                df.to_excel("save_ques_ans//"+str(token)+".xlsx", index=False)
                return gr.Label(label="Please keep the token for tracking question answer data",value=token,visible=True)
                
        
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
            y_lim=[1, 200],
            width=150,
            # height=1000,
            visible=True
        )
    with gr.Tab("Human Evaluation"):
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
        
        with gr.Row():
            new_user=gr.Button("New User")
        with gr.Row():
            new_user_token=gr.Label(visible=False)
        with gr.Row():
            token_key=gr.Textbox(label="Enter your Token")
            model_ans=gr.Dropdown(choices=os.listdir("model_ans"),label="Select the Model Answer for Human Evaluation")
        btn_1=gr.Button("Submit")
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
            human_ans_btn=gr.Button("Show Answer From Other Evaluators")
        with gr.Row():
            human_ans_lab=gr.Label(label="Human Answer",visible=False)   
        with gr.Row():
            btn = gr.Button("Save")
            question = gr.Button("Skip")
        # with gr.Row():
            # save_all_btn=gr.Button("Save all the data in dataframe")
        # with gr.Row():
        #     move=gr.Number(label="Move to the question")
        #     move_btn=gr.Button("move")
        with gr.Row():
            btn_plot=gr.Button("Plot Generation")
        with gr.Row():
            plot = gr.BarPlot(visible=False)
        btn_plot.click(bar_plot_fn, None, outputs=plot)
        btn_1.click(answer_updated,model_ans,[lab_temp,id,ques,ans,model_ans,btn_1])
        btn.click(score_save, inputs=[ques,ans,score,model_ans,token_key], outputs=[id,ques,ans])
        question.click(new_ques,model_ans,[id,ques,ans])
        # save_all_btn.click(save_all,model_ans,None)
        # move_btn.click(move_to,[move,model_ans],[id,ques,ans])
        def human_ans_func(id, ques):
            temp=all_contri_ans(id,ques)
            return [gr.Button("Show Answer from Other Evaluators"),gr.Label(value="\n".join(temp),visible=True)] 
        human_ans_btn.click(human_ans_func,[id, ques],[human_ans_btn,human_ans_lab])
        new_user.click(generate_token,None,new_user_token)
        
#***************************************************
    infer_ragchain=None
    with gr.Tab("Inference"):
        def echo(message, history,model_name_local,model_name_online,
                                            inf_checkbox,embedding_name,splitter_type_dropdown,chunk_size_slider,
                                            chunk_overlap_slider,separator_textbox,max_tokens_slider):
            global infer_ragchain
            if infer_ragchain is None:
                gr.Info("Please wait!!! model is loading!!")
                if inf_checkbox:
                    gr.info("local model is loading!!")
                infer_ragchain = model_chain(model_name_local,model_name_online,
                                            inf_checkbox,embedding_name,splitter_type_dropdown,chunk_size_slider,
                                            chunk_overlap_slider,separator_textbox,max_tokens_slider)
            rag_chain=infer_ragchain.rag_chain_ret()
            return infer_ragchain.ans_ret(message,rag_chain) 
        with gr.Row():
            embedding_name=gr.Dropdown(choices=["BAAI/bge-base-en-v1.5","dunzhang/stella_en_1.5B_v5","dunzhang/stella_en_400M_v5",
                                                "nvidia/NV-Embed-v2","Alibaba-NLP/gte-Qwen2-1.5B-instruct"],
                                    label="Select the Embedding Model")
            splitter_type_dropdown = gr.Dropdown(choices=["character", "recursive", "token"],
                                             value="character", label="Splitter Type",interactive=True)
            
            chunk_size_slider = gr.Slider(minimum=100, maximum=2000, value=500, step=50, label="Chunk Size")
            chunk_overlap_slider = gr.Slider(minimum=0, maximum=500, value=30, step=10, label="Chunk Overlap",interactive=True)
            separator_textbox = gr.Textbox(value="\n", label="Separator (e.g., newline '\\n')",interactive=True)
            max_tokens_slider = gr.Slider(minimum=100, maximum=5000, value=1000, step=100, label="Max Tokens",interactive=True)

        inf_checkbox=gr.Checkbox(label="Do you want to use fine-tuned model?")
        model_name_local=gr.Dropdown(visible=False)
        model_name_online=gr.Dropdown(choices=["Zephyr","Llama","Mistral", "Phi", "Flant5"],
                        label="Select the LLM from Huggingface",visible=True)
        def model_online_local_show(inf_checkbox):
            if inf_checkbox:
                return [gr.Dropdown(choices=os.listdir("models"),label="Select the local LLM",visible=True),
                        gr.Dropdown(visible=False)]
            else:
                return [gr.Dropdown(visible=False),
                        gr.Dropdown(choices=["Zephyr","Llama","Mistral", "Phi", "Flant5"],
                        label="Select the LLM from Huggingface",visible=True)]
        inf_checkbox.change(model_online_local_show,[inf_checkbox],[model_name_local,model_name_online])
        gr.ChatInterface(fn=echo, 
                         additional_inputs=[model_name_local,model_name_online,inf_checkbox,embedding_name,
                                            splitter_type_dropdown,chunk_size_slider,
                                            chunk_overlap_slider,separator_textbox,max_tokens_slider],
                           title="Chatbot")
    with gr.Tab("Deployment"):
        gr.Markdown("""\"deploy\" folder has all the code for the deployment of the model.
                    For installing dependencies use the following command: "pip install -r requirements.txt".
                    """)
        def deploy_func(model_name):
            f=open("deploy//info.txt","w")
            f.write(f"{model_name}")

            
        model_name=gr.Dropdown(choices=os.listdir("models"),label="Select the Model")
        btn_model=gr.Button("Deploy")
        btn_model.click(deploy_func,model_name)

demo.launch(share=False)