from typing import List
from fastapi import FastAPI, UploadFile, File, Form
from pydantic import BaseModel
from classifier import classify_image
from region_rules import get_disposal_guide
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware

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