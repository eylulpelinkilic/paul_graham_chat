from fastapi import FastAPI
from pydantic import BaseModel
from llama_cpp import Llama
from fastapi.middleware.cors import CORSMiddleware

# GGUF model yolu
MODEL_PATH = "./models/mistral-7b-openorca.gguf2.Q4_0.gguf"

# Modeli yükle (yükleme birkaç saniye sürebilir)
llm = Llama(model_path=MODEL_PATH, n_ctx=2048, n_threads=4)

# FastAPI uygulaması
app = FastAPI()

origins = [
	"http://localhost:3000",
	"http://172.20.10.14:8000"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Gelen veriyi temsil eden model
class PromptRequest(BaseModel):
    prompt: str
# /generate endpoint'i
@app.post("/generate")
def generate_text(req: PromptRequest):
    result = llm(
        f"### Human: {req.prompt}\n### Assistant:",
        max_tokens=512,
        stop=["### Human:"],
	echo=True
    )
    return {"response": result["choices"][0]["text"].strip()}
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
