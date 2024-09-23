import os
import pandas as pd
from datasets import Dataset
from sentence_transformers import SentenceTransformer
from sentence_transformers.evaluation import (
    InformationRetrievalEvaluator,
    SequentialEvaluator,
)
from sentence_transformers.util import cos_sim
from datasets import concatenate_datasets
import torch

def train_model_with_custom_dataset(file_path, model_name, sheet_name=None):
    # Load the dataset from Excel or CSV
    if file_path.endswith(".csv"):
        df = pd.read_csv(file_path)
    elif file_path.endswith(".xlsx") and sheet_name:
        df = pd.read_excel(file_path, sheet_name=sheet_name)
    else:
        df = pd.read_excel(file_path)

    # Ensure necessary columns exist
    if "question" not in df.columns or "context" not in df.columns:
        raise ValueError("Dataset must contain 'question' and 'context' columns")

    # Rename columns to match required format
    df = df.rename(columns={"question": "anchor", "context": "positive"})

    # Convert DataFrame to Hugging Face Dataset
    dataset = Dataset.from_pandas(df)

    # Add an 'id' column
    dataset = dataset.add_column("id", range(len(dataset)))

    # Split dataset into train/test sets (10% test set)
    dataset = dataset.train_test_split(test_size=0.1)

    # Save datasets to disk
    dataset["train"].to_json("train_dataset.json", orient="records")
    dataset["test"].to_json("test_dataset.json", orient="records")

    # Load model from Hugging Face
    model = SentenceTransformer(model_name, device="cuda" if torch.cuda.is_available() else "cpu")

    # Load test dataset
    test_dataset = Dataset.from_json("test_dataset.json")
    train_dataset = Dataset.from_json("train_dataset.json")
    corpus_dataset = concatenate_datasets([train_dataset, test_dataset])

    # Convert the datasets to dictionaries
    corpus = dict(zip(corpus_dataset["id"], corpus_dataset["positive"]))
    queries = dict(zip(test_dataset["id"], test_dataset["anchor"]))

    # Create a mapping of relevant document (1-to-1 mapping in our case)
    relevant_docs = {q_id: [q_id] for q_id in queries}

    # Set matryoshka dimensions for evaluation
    matryoshka_dimensions = [768, 512, 256, 128, 64]
    matryoshka_evaluators = []

    # Iterate over the different dimensions
    for dim in matryoshka_dimensions:
        ir_evaluator = InformationRetrievalEvaluator(
            queries=queries,
            corpus=corpus,
            relevant_docs=relevant_docs,
            name=f"dim_{dim}",
            truncate_dim=dim,  # Truncate the embeddings to a certain dimension
            score_functions={"cosine": cos_sim},
        )
        matryoshka_evaluators.append(ir_evaluator)

    # Create a sequential evaluator
    evaluator = SequentialEvaluator(matryoshka_evaluators)

    # Evaluate the model
    results = evaluator(model)

    # Print the main score for each dimension
    for dim in matryoshka_dimensions:
        key = f"dim_{dim}_cosine_ndcg@10"
        if key in results:
            print(f"{key}: {results[key]}")

    # Set up training arguments
    from sentence_transformers import SentenceTransformerTrainingArguments, SentenceTransformerTrainer
    from sentence_transformers.losses import MatryoshkaLoss, MultipleNegativesRankingLoss

    inner_train_loss = MultipleNegativesRankingLoss(model)
    train_loss = MatryoshkaLoss(model, inner_train_loss, matryoshka_dims=matryoshka_dimensions)

    # Define the model save directory as "embedding_model/<model_name>"
    save_dir = os.path.join("embedding_model", model_name.replace("/","_"))
    os.makedirs(save_dir, exist_ok=True)  # Create the directory if it doesn't exist

    args = SentenceTransformerTrainingArguments(
        output_dir=save_dir,                         # Output directory using the model name
        num_train_epochs=4,                            # Number of epochs
        per_device_train_batch_size=32,                # Training batch size
        gradient_accumulation_steps=16,                # For a global batch size of 512
        per_device_eval_batch_size=16,                 # Evaluation batch size
        warmup_ratio=0.1,                              # Warmup ratio
        learning_rate=2e-5,                            # Learning rate
        lr_scheduler_type="cosine",                    # Cosine learning rate scheduler
        optim="adamw_torch_fused",                     # Fused AdamW optimizer
        tf32=True,                                     # Use tf32 precision
        bf16=True,                                     # Use bf16 precision
        evaluation_strategy="epoch",                   # Evaluate after each epoch
        save_strategy="epoch",                         # Save after each epoch
        logging_steps=10,                              # Log every 10 steps
        save_total_limit=3,                            # Save the last 3 models
        load_best_model_at_end=True,                   # Load the best model at the end of training
        metric_for_best_model="eval_dim_128_cosine_ndcg@10",  # Metric for choosing the best model
    )

    # Initialize the trainer
    trainer = SentenceTransformerTrainer(
        model=model,
        args=args,
        train_dataset=train_dataset.select_columns(["positive", "anchor"]),
        loss=train_loss,
        evaluator=evaluator,
    )

    # Train the model
    trainer.train()

    # Save the best model to the "embedding_model/<model_name>" directory
    trainer.save_model(save_dir)

# Example usage:
# train_model_with_custom_dataset("your_dataset.csv", "BAAI/bge-base-en-v1.5")
