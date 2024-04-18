import gradio as gr
with gr.Blocks() as demo:
    with gr.Tab("Inference"):
            def echo(message, history,model_name):
                gr.Info("Please wait!!! Model is loading!!")
                #$$$$$$$$$$$$$$$$$
                # rag_chain=rag_chain_ret("My_model")
                # return ans_ret(message,rag_chain)
                return "Llama"
            
            gr.ChatInterface(fn=echo, title="My chatbot")
demo.launch(share=False)