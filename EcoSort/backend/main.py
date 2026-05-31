from typing import List
from fastapi import FastAPI, UploadFile, File, Form
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from backend.classifier import classify_image
from backend.region_rules import get_disposal_guide, get_region_from_coords
from backend.chatbot import ask_chatbot

app = FastAPI(title="Waste Sorting MVP")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class AnalyzeResponse(BaseModel):
    item_name: str
    category: str
    confidence: float
    region: str
    disposal_steps: List[str]
    disposal_notes: List[str]

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    answer: str

class RegionResponse(BaseModel):
    sido: str
    sigungu: str
    full_name: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze(
    file: UploadFile = File(...),
    lat: float = Form(...),
    lon: float = Form(...)
):
    image_bytes = await file.read()
    result = classify_image(file.filename, image_bytes)
    guide = get_disposal_guide(result["category"], lat, lon)
    return {**result, **guide}

@app.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest):
    answer = ask_chatbot(request.message)
    return {"answer": answer}

@app.get("/region", response_model=RegionResponse)
def get_region(lat: float, lon: float):
    sido, sigungu = get_region_from_coords(lat, lon)
    return {
        "sido": sido,
        "sigungu": sigungu,
        "full_name": f"{sido} {sigungu}" if sido else "위치 미확인"
    }