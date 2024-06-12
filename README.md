
# ✨ LLM based QA chatbot builder
## 🏁 An end-to-end solution to develop a fully open-source application based on open-source models and libraries without an API key.

### 🎯 What Is LLM based QA chatbot builder?
There are various stages involved in developing an LLM-based QA chatbot: a) collecting and preprocessing data; b) fine-tuning, testing, and inference of the LLM; and c) developing the chat interface. In this work, we offer the LLM QA builder, a web application that assembles all the processes and simplifies the building of the LLM QA chatbot for both technical and non-technical users, in an effort to speed this development process. Zepyhr, Mistral, Llama-3, Phi, Flan-T5, and a user-provided model for retrieving information relevant to an organization can all be fine-tuned using the system; these LLMs can then be further improved through the application of retrieval-augmented generation (RAG) approaches. We have included an automatic RAG data scraper that is based on web crawling. Furthermore, our system has a human evaluation component to determine the quality of the model. 


## 🎯 Features


| 🦾 Model Support             | Implemented | Description                                   |
|------------------------------|-------------|-----------------------------------------------|
| **Mistral**                  | ✅           | Fine-tuning Model powered by Mistral         |
| **Zephyr**                   | ✅           | Fine-tuning Model powered by HuggingFace      |
| **Llama-3**                  | ✅           | Fine-tuning Model powered by Facebook    |
| **Microsoft Phi-3**          | ✅           | Fine-tuning Model powered by Microsoft  |
| **Flan-T5**                  | ✅           | Fine-tuning Model powered by Google    |
| **ColBERT**                  | ✅           | Embedding Model     |
| **bge-large-en-v1.5**        | ✅           | Embedding Model |

🔀 Here is the diagram of the software architecture.
![Software Architecture](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/KUET%20LLM2.png)

## ⭐ Key Features

1️⃣ **Data collection:** Collect data from users or Excel files, and automatically build RAG data using a web crawler.

🖼️
![Data collection](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/data%20collection.png)

2️⃣ **Finetune:** Fine-tune state-of-the-art models (e.g., Mistral, Llama, Zephyr, Phi-3) and lightweight models (e.g., Flan-T5).

🖼️
![Finetune](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/Finetuning.png)


3️⃣ **Testing data generation:** Generate test data using the fine-tuned models.

🖼️
![Testing data generation](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/Testing%20data%20generation%20from%20model.png)

4️⃣  **Human evaluation:** Evaluate model performance based on user ratings.

🖼️
![Human evaluation](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/Human%20evaluation.png)

5️⃣  **Inference:** Perform inference using the fine-tuned models.

🖼️
![Inference](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/inference.png)

6️⃣ **Deployment:** Deploy the fine-tuned models.

🖼️
![Deployment](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/deployment.png)
## 🎯 Getting started
### 🚀 Installation
```
git clone https://github.com/shahidul034/LLM-based-QA-chatbot-builder
```
```bash
conda create -n llm python=3.10
conda activate llm
pip install torch torchvision torchaudio jupyter langchainhub sentence-transformers faiss-gpu docx2txt langchain bitsandbytes transformers peft accelerate pynvml trl datasets packaging ninja wandb colbert-ai[torch,faiss-gpu] RAGatouille
pip install -U flash-attn --no-build-isolation

```
or 
```
pip install -r requirements.txt
```
## Run
```
cd UI
python full_UI.py
```
## 🎯 Contributing

Contributions are always welcome!



## 🎯 License

[MIT](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/LICENSE)

