from transformers import AutoTokenizer, AutoModelForCausalLM, T5Tokenizer, T5ForConditionalGeneration, pipeline
from langchain import HuggingFacePipeline
import os
import torch

def load_model_and_pipeline(model_info, quantization=4, is_t5=False, use_online=True,temperature=0):
    
    tokenizer = AutoTokenizer.from_pretrained(model_info, use_auth_token=True)
    print("*"*20, quantization,"  t5: ", is_t5,"  type: ", type(quantization))
    if quantization == 8 and not is_t5:
        model = AutoModelForCausalLM.from_pretrained(
            model_info,
            device_map='auto',
            torch_dtype=torch.float16,
            use_auth_token=True,
            load_in_8bit=True
        )
    elif not is_t5 and quantization==4:
        model = AutoModelForCausalLM.from_pretrained(
            model_info,
            device_map='auto',
            torch_dtype=torch.float16,
            use_auth_token=True,
            load_in_4bit=True
        )

    if is_t5:
        model = T5ForConditionalGeneration.from_pretrained(model_info)
        tokenizer = T5Tokenizer.from_pretrained("google/flan-t5-base")

    pipe = pipeline(
        "text-generation",
        model=model,
        tokenizer=tokenizer,
        torch_dtype=torch.bfloat16,
        device_map="auto",
        max_new_tokens=512,
        do_sample=True,
        top_k=30,
        num_return_sequences=1,
        eos_token_id=tokenizer.eos_token_id
    )

    llm = HuggingFacePipeline(pipeline=pipe, model_kwargs={'temperature': temperature})
    return tokenizer, model, llm

def zephyr_model(model_info, quantization, use_online=True):
    return load_model_and_pipeline(model_info, quantization, use_online=use_online)

def llama_model(model_info, quantization, use_online=True):
    return load_model_and_pipeline(model_info, quantization, use_online=use_online)

def mistral_model(model_info, quantization, use_online=True):
    return load_model_and_pipeline(model_info, quantization, use_online=use_online)

def phi_model(model_info, quantization, use_online=True):
    return load_model_and_pipeline(model_info, quantization, use_online=use_online)

def flant5_model(model_info, use_online=True):
    return load_model_and_pipeline(model_info, is_t5=True, use_online=use_online)


import pandas as pd
from datasets import Dataset

def calculate_rag_metrics(model_ques_ans_gen, llm_model, embedding_model="BAAI/bge-base-en-v1.5"):
    # Create a dictionary from the model_ques_ans_gen list
    from ragas import evaluate
    from ragas.metrics import faithfulness, answer_correctness,answer_similarity,answer_relevancy,context_recall, context_precision
    data_samples = {
        'question': [item['question'] for item in model_ques_ans_gen],
        'answer': [item['answer'] for item in model_ques_ans_gen],
        'contexts': [item['contexts'] for item in model_ques_ans_gen],
        'ground_truths': [item['ground_truths'] for item in model_ques_ans_gen]
    }

    # Convert the dictionary to a pandas DataFrame
    rag_df = pd.DataFrame(data_samples)

    # Convert the DataFrame to a HuggingFace Dataset
    rag_eval_dataset = Dataset.from_pandas(rag_df)

    # Define the list of metrics to calculate
    metrics = [
        "answer_correctness", "answer_similarity", 
        "answer_relevancy", "faithfulness", 
        "context_recall", "context_precision"
    ]

    # Perform the evaluation using the provided LLM and embedding models
    result = evaluate(
        rag_eval_dataset,
        metrics=metrics,
        llm=llm_model,
        embeddings=embedding_model
    )
    result.to_pandas()
    return result