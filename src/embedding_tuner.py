from datasets import load_dataset, Dataset
from sentence_transformers import (
    SentenceTransformer,
    SentenceTransformerTrainer,
    SentenceTransformerTrainingArguments,
)
from sentence_transformers.losses import (
    MultipleNegativesRankingLoss,
    OnlineContrastiveLoss,
    CoSENTLoss,
    GISTEmbedLoss,
    TripletLoss,
)
import pandas as pd


class EmbeddingFinetuner:
    """
    A class for finetuning SentenceTransformer models on various loss functions.

    Supports the following loss functions:
        - MultipleNegativesRankingLoss
        - OnlineContrastiveLoss
        - CoSENTLoss
        - GISTEmbedLoss
        - TripletLoss

    Loads data from an xlsx file named "emb_data.xlsx".
    """

    def __init__(
        self,
        model_name="microsoft/mpnet-base",
        loss_function="MultipleNegativesRankingLoss",
        epochs=1,
        batch_size=16,
        test_size=0.1,
    ):
        """
        Initializes the EmbeddingFinetuner.

        Args:
            model_name (str): Name of the SentenceTransformer model to use.
            loss_function (str): Name of the loss function to use.
            epochs (int): Number of training epochs.
            batch_size (int): Batch size for training.
            test_size (float): Proportion of the dataset to include in the test split. 
                              If less than 1, no test set is created.
        """
        self.model_name = model_name
        self.loss_function = loss_function
        self.epochs = epochs
        self.batch_size = batch_size
        self.test_size = test_size

        self.model = SentenceTransformer(self.model_name)
        self.train_dataset, self.dev_dataset, self.test_dataset = self._load_data()
        self.loss = self._get_loss_function()

    def _load_data(self):
        """
        Loads data from "emb_data.xlsx" and prepares it for the selected loss function.
        """
        df = pd.read_excel(f"data/emb_data.xlsx")

        if self.loss_function == "MultipleNegativesRankingLoss":
            """
            Expects data in the format:
            | anchor | positive | negative |
            |---|---|---|
            | sentence1 | sentence2 | sentence3 |
            | ... | ... | ... |

            Where 'anchor' is the sentence to be embedded, 'positive' is a sentence 
            semantically similar to the anchor, and 'negative' is a sentence 
            semantically dissimilar to the anchor.
            """
            dataset = Dataset.from_pandas(df)

        elif self.loss_function == "OnlineContrastiveLoss":
            """
            Expects data in the format:
            | sentence1 | sentence2 | label |
            |---|---|---|
            | sentenceA | sentenceB | 1 | 
            | sentenceC | sentenceD | 0 |
            | ... | ... | ... |

            Where 'sentence1' and 'sentence2' are pairs of sentences, and 'label' 
            indicates whether they are semantically similar (1) or dissimilar (0).
            """
            dataset = Dataset.from_pandas(df)

        elif self.loss_function == "CoSENTLoss":
            """
            Expects data in the format:
            | sentence1 | sentence2 | score |
            |---|---|---|
            | sentenceA | sentenceB | 0.8 |
            | sentenceC | sentenceD | 0.2 |
            | ... | ... | ... |

            Where 'sentence1' and 'sentence2' are pairs of sentences, and 'score' 
            is a float value representing their similarity (e.g., from 0 to 1).
            """
            dataset = Dataset.from_pandas(df)

        elif self.loss_function == "GISTEmbedLoss":
            """
            Expects data in either of the following formats:

            Triplets:
            | anchor | positive | negative |
            |---|---|---|
            | sentence1 | sentence2 | sentence3 |
            | ... | ... | ... |

            Pairs:
            | anchor | positive |
            |---|---|
            | sentence1 | sentence2 |
            | ... | ... |

            Where 'anchor' is the sentence to be embedded, 'positive' is a sentence 
            semantically similar to the anchor, and 'negative' (if present) is a 
            sentence semantically dissimilar to the anchor.
            """
            dataset = Dataset.from_pandas(df)

        elif self.loss_function == "TripletLoss":
            """
            Expects data in the format:
            | anchor | positive | negative |
            |---|---|---|
            | sentence1 | sentence2 | sentence3 |
            | ... | ... | ... |

            Where 'anchor' is the sentence to be embedded, 'positive' is a sentence 
            semantically similar to the anchor, and 'negative' is a sentence 
            semantically dissimilar to the anchor.
            """
            dataset = Dataset.from_pandas(df)

        else:
            raise ValueError(f"Unsupported loss function: {self.loss_function}")

        # Split into train and dev
        train_dev_dataset = dataset.train_test_split(test_size=self.test_size)
        train_dataset = train_dev_dataset["train"]
        dev_dataset = train_dev_dataset["test"]
        test_dataset = None

        return train_dataset, dev_dataset, test_dataset

    def _get_loss_function(self):
        """
        Returns the selected loss function instance.
        """
        if self.loss_function == "MultipleNegativesRankingLoss":
            return MultipleNegativesRankingLoss(self.model)
        elif self.loss_function == "OnlineContrastiveLoss":
            return OnlineContrastiveLoss(self.model)
        elif self.loss_function == "CoSENTLoss":
            return CoSENTLoss(self.model)
        elif self.loss_function == "GISTEmbedLoss":
            guide_model = SentenceTransformer("all-MiniLM-L6-v2")  # You can change this
            return GISTEmbedLoss(self.model, guide_model)
        elif self.loss_function == "TripletLoss":
            return TripletLoss(self.model)
        else:
            raise ValueError(f"Unsupported loss function: {self.loss_function}")

    def train(self):
        """
        Trains the SentenceTransformer model using the specified loss function.
        """
        args = SentenceTransformerTrainingArguments(
            output_dir=f"models/{self.model_name}-{self.loss_function}",
            num_train_epochs=self.epochs,
            per_device_train_batch_size=self.batch_size,
            per_device_eval_batch_size=self.batch_size,
            evaluation_strategy="epoch",
            # ... other training arguments as needed ...
        )

        trainer = SentenceTransformerTrainer(
            model=self.model,
            args=args,
            train_dataset=self.train_dataset,
            eval_dataset=self.dev_dataset,
            loss=self.loss,
        )
        trainer.train()

        # Save the trained model
        self.model.save_pretrained(
            f"models/emb-{self.model_name}-{self.loss_function}"
        )
        
        return True
        
        
