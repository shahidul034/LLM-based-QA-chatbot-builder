import gradio as gr
from inference_deploy import rag_chain_ret
from inference_deploy import ans_ret 
with gr.Blocks() as demo:
    with gr.Tab("Inference"):
            f=open("deploy//info.txt","r").read().split("\n")
            username=f[0]
            model_name=f[1]
            rag_chain=rag_chain_ret(f"{username}/{model_name}")
            def echo(message, history,model_name):
                gr.Info("Please wait!!! Model is loading!!")
                # return ans_ret(message,rag_chain)
                return "message"

            gr.ChatInterface(fn=echo, title="My chatbot")
demo.launch(share=False)