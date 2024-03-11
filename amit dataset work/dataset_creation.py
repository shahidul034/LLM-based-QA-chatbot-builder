import pandas as pd
def dataset_gen():
    from datasets import load_from_disk
    dataset = load_from_disk("data")
    return dataset

def display_table(front):
    # Replace index names with custom labels
    df = pd.DataFrame(dataset[front])
    df=df.drop(['id'],axis=1)
    text=" ".join(dataset[int(front)]['tokens'])
    df_with_custom_index = df.copy()
    df_with_custom_index.index = [f"Row {i+1}" for i in range(len(df))]
    
    # Convert DataFrame with custom index to HTML table
    html_table = df_with_custom_index.to_html(index=True)
    
    # Wrapping HTML table with Gradio Text
    return f"<div style='overflow-x:auto;'>{html_table}</div>"


def pos_ner_show(tok_text,pos_tag,ner_tag):
    # Replace index names with custom labels
    import ast
    tok_text = ast.literal_eval(tok_text)
    data={
        "tokens": tok_text,
        "pos_tag":pos_tag.split(","),
        'ner_tag':ner_tag.split(",")
    }
    print(data)
    df = pd.DataFrame(data)
    df_with_custom_index = df.copy()
    df_with_custom_index.index = [f"Row {i+1}" for i in range(len(df))]
    
    # Convert DataFrame with custom index to HTML table
    html_table = df_with_custom_index.to_html(index=True)
    
    # Wrapping HTML table with Gradio Text
    return {lab_pos_ner: gr.Label(visible=True,value=f"<div style='overflow-x:auto;'>{html_table}</div>"),
        # lab: gr.Label(visible=True,elem_id="accepted",value="Submitted")
    }

def show_tok(tran_text):
    import nltk
    # nltk.download('punkt')
    tokens = nltk.word_tokenize(tran_text)
    return {
                tok_text: gr.Label(value=f"{tokens}")
        }

def save_data(tok_text,pos_tag,ner_tag):
    import pandas as pd
    front=int(open("current_data.txt","r").read())
    df = pd.read_excel('data.xlsx')
    import ast
    tok_text = ast.literal_eval(tok_text)
    # if len(tok_text)==len(pos_tag.split(",")) and len(tok_text)==len(ner_tag.split(",")):
    #     return {lab: gr.Label(visible=True,elem_id="wrong",value="Error!!!"),    
    #         }
    data={
        'id':front,
        "tokens": tok_text,
        "pos_tag":pos_tag.split(","),
        'ner_tag':ner_tag.split(",")
    }
    front=front+1
    open("current_data.txt","w").write(f"{front}")
    df = df._append(data, ignore_index=True)
    df.to_excel('data.xlsx', index=False)
    return {lab: gr.Label(visible=True,elem_id="accepted",value="Submitted"),
            show_text1 : gr.HTML(value=display_table(front)),
            show_text2 : gr.Textbox(value=" ".join(dataset[int(front)]['tokens']))         
            }
import gradio as gr
css = """
#accepted {background-color: green;align-content: center;font: 30px Arial, sans-serif;}
#wrong {background-color: red;align-content: center;font: 30px Arial, sans-serif;}
#already {background-color: blue;align-content: center;font: 30px Arial, sans-serif;}
"""
dataset=dataset_gen()
front=int(open("current_data.txt","r").read())
text=" ".join(dataset[int(front)]['tokens'])
with gr.Blocks(css=css) as demo:
    with gr.Row():
        gr.Label(value="https://huggingface.co/datasets/conll2003")
    with gr.Row():
        show_text1 = gr.HTML(value=display_table(front))
        show_text2 = gr.Textbox(value=text)
    with gr.Row():
        tran_text=gr.Textbox(label="Enter translated text",info="sample of input: ঐতিহাসিক ৭ মার্চে বঙ্গবন্ধুর স্মৃতির প্রতি প্রধানমন্ত্রীর শ্রদ্ধা")
    with gr.Row():
        tok_text=gr.Label(label="Tokenized text")
    with gr.Row():
        pos_tag = gr.Textbox(label="Enter POS tag",info="sample of input: 22, 42, 16, 21, 35, 37, 16, 21, 7")
    with gr.Row():
        ner_tag = gr.Textbox(label="Enter NER tag",info="sample of input: 22, 42, 16, 21, 35, 37, 16, 21, 7")
    with gr.Row():
        lab_pos_ner = gr.HTML(visible=False)
    with gr.Row():
        check = gr.Button("Check")
        save = gr.Button("Save the data")
    with gr.Row():
        lab=gr.Label(visible=False)
    tran_text.change(show_tok,tran_text,tok_text)
    check.click(pos_ner_show,[tok_text,pos_tag,ner_tag],[lab_pos_ner])
    save.click(save_data,[tok_text,pos_tag,ner_tag],[lab,show_text1,show_text2])

demo.launch(share=False)