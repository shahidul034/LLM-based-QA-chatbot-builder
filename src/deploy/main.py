import gradio as gr
import os
from utils import load_params_from_file
from inference import model_chain

infer_ragchain = None

# Define the main interface logic
def echo(message, history, model_name_local, model_name_online,
         inf_checkbox, embedding_name, splitter_type_dropdown, chunk_size_slider,
         chunk_overlap_slider, separator_textbox, max_tokens_slider):
    global infer_ragchain
    if infer_ragchain is None:
        gr.Info("Please wait!!! model is loading!!")
        if inf_checkbox:
            gr.info("local model is loading!!")
        infer_ragchain = model_chain(model_name_local, model_name_online,
                                     inf_checkbox, embedding_name, splitter_type_dropdown, chunk_size_slider,
                                     chunk_overlap_slider, separator_textbox, max_tokens_slider)
    rag_chain = infer_ragchain.rag_chain_ret()
    return infer_ragchain.ans_ret(message, rag_chain)

# Load saved parameters if available
saved_params = load_params_from_file()

# Set default values
default_embedding_name = saved_params['embedding_name'] if saved_params else "BAAI/bge-base-en-v1.5"
default_splitter_type = saved_params['splitter_type_dropdown'] if saved_params else "character"
default_chunk_size = saved_params['chunk_size_slider'] if saved_params else 500
default_chunk_overlap = saved_params['chunk_overlap_slider'] if saved_params else 30
default_separator = saved_params['separator_textbox'] if saved_params else "\n"
default_max_tokens = saved_params['max_tokens_slider'] if saved_params else 1000

# Initialize the Gradio Interface
with gr.Blocks() as demo:
    with gr.Tab("Inference"):
        with gr.Row():
            embedding_name = gr.Dropdown(choices=["BAAI/bge-base-en-v1.5", "dunzhang/stella_en_1.5B_v5", "dunzhang/stella_en_400M_v5",
                                                  "nvidia/NV-Embed-v2", "Alibaba-NLP/gte-Qwen2-1.5B-instruct"],
                                         value=default_embedding_name, label="Select the Embedding Model")
            splitter_type_dropdown = gr.Dropdown(choices=["character", "recursive", "token"],
                                                 value=default_splitter_type, label="Splitter Type", interactive=True)

            chunk_size_slider = gr.Slider(minimum=100, maximum=2000, value=default_chunk_size, step=50, label="Chunk Size")
            chunk_overlap_slider = gr.Slider(minimum=0, maximum=500, value=default_chunk_overlap, step=10, label="Chunk Overlap", interactive=True)
            separator_textbox = gr.Textbox(value=default_separator, label="Separator (e.g., newline '\\n')", interactive=True)
            max_tokens_slider = gr.Slider(minimum=100, maximum=5000, value=default_max_tokens, step=100, label="Max Tokens", interactive=True)

        inf_checkbox = gr.Checkbox(label="Do you want to use a fine-tuned model?")
        model_name_local = gr.Dropdown(visible=False)
        model_name_online = gr.Dropdown(choices=["Zephyr", "Llama", "Mistral", "Phi", "Flant5"],
                                        label="Select the LLM from Huggingface", visible=True)

        # Function to toggle model selection between local and online based on checkbox
        def model_online_local_show(inf_checkbox):
            if inf_checkbox:
                return [gr.Dropdown(choices=os.listdir("models"), label="Select the local LLM", visible=True),
                        gr.Dropdown(visible=False)]
            else:
                return [gr.Dropdown(visible=False),
                        gr.Dropdown(choices=["Zephyr", "Llama", "Mistral", "Phi", "Flant5"],
                                    label="Select the LLM from Huggingface", visible=True)]

        # Event listener to switch between local and online models
        inf_checkbox.change(model_online_local_show, [inf_checkbox], [model_name_local, model_name_online])

        # Chat interface
        gr.ChatInterface(fn=echo,
                         additional_inputs=[model_name_local, model_name_online, inf_checkbox, embedding_name,
                                            splitter_type_dropdown, chunk_size_slider,
                                            chunk_overlap_slider, separator_textbox, max_tokens_slider],
                         title="Chatbot")

# Launch the demo
demo.launch()
