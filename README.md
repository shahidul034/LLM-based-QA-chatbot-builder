
# LLM based QA chatbot builder
## An end-to-end solution to develop a fully open-source application based on open-source models and libraries without an API key.

### What Is LLM based QA chatbot builder?
There are various stages involved in developing an LLM-based QA chatbot: a) collecting and preprocessing data; b) fine-tuning, testing, and inference of the LLM; and c) developing the chat interface. In this work, we offer the LLM QA builder, a web application that assembles all the processes and simplifies the building of the LLM QA chatbot for both technical and non-technical users, in an effort to speed this development process. Zepyhr, Mistral, Llama-3, Phi, Flan-T5, and a user-provided model for retrieving information relevant to an organization can all be fine-tuned using the system; these LLMs can then be further improved through the application of retrieval-augmented generation (RAG) approaches. We have included an automatic RAG data scraper that is based on web crawling. Furthermore, our system has a human evaluation component to determine the quality of the model. 


## Features

![Software Architecture](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/KUET%20LLM2.png)

**Data collection:** Collect data from users or as Excel files.
![Data collection](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/data%20collection.png)

**Finetune:** Finetune the latest model(Mistral,Llama, Zepyhr,Phi-3) and lightweight model(Flan-T5)
![Finetune](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/Finetuning.png)


**Testing data generation:** Generate the data from testing data using the fine-tune models
![Testing data generation](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/Testing%20data%20generation%20from%20model.png)

**Human evaluation:** Evaluate the models from users(Rating based)
![Human evaluation](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/Human%20evaluation.png)

**Inference:** Inference from the models
![Inference](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/inference.png)

**Deployment:** Deploy the finetuned models.
![Deployment](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/software%20screenshot/deployment.png)
## Getting started
### Installation
```
git clone https://github.com/shahidul034/LLM-based-QA-chatbot-builder
```
```bash
conda create -n llm python=3.10
conda activate llm
pip install torch torchvision torchaudio jupyter langchainhub sentence-transformers faiss-gpu docx2txt langchain bitsandbytes transformers peft accelerate pynvml trl datasets packaging ninja wandb colbert-ai[torch,faiss-gpu] gradio RAGatouille
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
## Contributing

Contributions are always welcome!



## License

[MIT](https://github.com/shahidul034/LLM-based-QA-chatbot-builder/blob/main/LICENSE)

