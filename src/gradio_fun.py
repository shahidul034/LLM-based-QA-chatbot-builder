import gradio as gr
import os
def model_online_local_show(inf_checkbox):
            if inf_checkbox:
                return [gr.Dropdown(choices=os.listdir("models"),label="Select the local LLM",visible=True),
                        gr.Dropdown(visible=False)]
            else:
                return [gr.Dropdown(visible=False),
                        gr.Dropdown(choices=["Zephyr","Llama","Mistral", "Phi", "Flant5"],
                        label="Select the LLM from Huggingface",visible=True)]