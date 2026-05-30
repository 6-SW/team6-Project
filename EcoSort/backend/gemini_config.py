# 공통 설정 파일
import os
from pathlib import Path
from dotenv import load_dotenv
import google.generativeai as genai

ENV_PATH = Path(__file__).resolve().parent / ".env"
load_dotenv(dotenv_path=ENV_PATH)

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise RuntimeError("GEMINI_API_KEY가 backend/.env에 없습니다.")

genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-2.5-flash")