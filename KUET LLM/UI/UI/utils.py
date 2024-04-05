import pandas as pd
import datetime
import gradio as gr
def display_table():
    # Replace index names with custom labels
    df = pd.read_excel(r"data/data.xlsx")
    df_with_custom_index = df.head(2)
    # df_with_custom_index.index = [f"Row {i+1}" for i in range(len(df_with_custom_index))]
            
        # Convert DataFrame with custom index to HTML table
    html_table = df_with_custom_index.to_html(index=True)
            
    # Wrapping HTML table with Gradio Text
    return f"<div style='overflow-x:auto;'>{html_table}</div>"
def file_df():
    ff="model_ans_llama_finetuned486_rag_ensemble"
    df=pd.read_excel(r"model_ans/model_ans_mistral_finetuned486_rag_ensemble.xlsx")
    current_datetime = datetime.datetime.now()
    file_name = current_datetime.strftime("%Y_%m_%d_%H_%M_%S")+ff
    return df,file_name,ff,current_datetime.strftime("%Y_%m_%d_%H_%M_%S")
def random_ques_ans2():
    import random
    import pandas as pd
    df=pd.read_excel(r"data/ques_list.xlsx")
    id=random.randint(0,59)
    ques_temp=(df.loc[id])['question']
    ans_temp=(df.loc[id])['answer']
    return ques_temp,ans_temp

