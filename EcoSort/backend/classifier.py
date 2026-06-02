import json

from backend.category_catalog import (
    build_category_prompt,
    build_selected_category_prompt,
    normalize_category_answer,
    normalize_category_key,
)
from backend.gemini_config import model


def classify_image(file_name: str, image_bytes: bytes) -> dict:
    prompt = build_category_prompt()
    image_part = {"mime_type": "image/jpeg", "data": image_bytes}
    response = model.generate_content([prompt, image_part])

    label, category = normalize_category_answer(response.text)

    return {
        "item_name": label,
        "category": category,
        "confidence": 1.0,
    }


def _parse_json_object(text: str) -> dict:
    cleaned = (text or "").strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.strip("`")
        if cleaned.startswith("json"):
            cleaned = cleaned[4:].strip()

    start = cleaned.find("{")
    end = cleaned.rfind("}")
    if start != -1 and end != -1:
        cleaned = cleaned[start : end + 1]

    return json.loads(cleaned)


def analyze_selected_category(
    file_name: str,
    image_bytes: bytes,
    selected_category: str,
) -> dict:
    label, category = normalize_category_key(selected_category)
    prompt = build_selected_category_prompt(category)
    image_part = {"mime_type": "image/jpeg", "data": image_bytes}
    response = model.generate_content([prompt, image_part])

    try:
        parsed = _parse_json_object(response.text)
    except Exception:
        parsed = {
            "item_name": label,
            "disposal_steps": [],
            "disposal_notes": [(response.text or "").strip()],
        }

    return {
        "item_name": parsed.get("item_name") or label,
        "category": category,
        "confidence": 1.0,
        "disposal_steps": parsed.get("disposal_steps") or [],
        "disposal_notes": parsed.get("disposal_notes") or [],
    }