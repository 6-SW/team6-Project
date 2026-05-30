from backend.gemini_config import model

CATEGORY_MAP = {
    "페트병": "pet",
    "플라스틱": "plastic",
    "유리병": "glass",
    "캔": "can",
    "종이": "paper",
    "비닐": "vinyl",
    "음식물": "food",
    "일반쓰레기": "general",
}

def classify_image(file_name: str, image_bytes: bytes) -> dict:
    prompt = """
    이 사진의 쓰레기 종류를 아래 중 단어 하나로만 답해줘
    페트병, 플라스틱, 유리병, 캔, 종이, 비닐, 음식물, 일반쓰레기
    """

    image_part = {"mime_type": "image/jpeg", "data": image_bytes}
    response = model.generate_content([prompt, image_part])

    answer = response.text.strip()
    category = CATEGORY_MAP.get(answer, "general")

    return {
        "item_name": answer,
        "category": category,
        "confidence": 1.0
    }