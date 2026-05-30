from backend.gemini_config import model

SYSTEM_PROMPT = """
분리배출 안내 챗봇이다.
사용자 질문에 한국어로 친절하고 짧게 답변한다.

답변 규칙:
1. 분리배출 방법은 단계별로 설명한다.
2. 필요하면 세척, 라벨 제거, 뚜껑 분리 같은 주의사항을 알려준다.
3. 지역 기준이 다를 수 있으면 '지자체 기준 확인 필요'를 덧붙인다.
4. 위험한 폐기물은 안전 주의사항을 먼저 말한다.
"""

def ask_chatbot(message: str) -> str:
    prompt = f"""
{SYSTEM_PROMPT}

사용자 질문:
{message}
"""

    response = model.generate_content(prompt)
    answer = (response.text or "").strip()

    if not answer:
        return "지금은 답변을 생성하지 못했습니다. 다시 시도해주세요."

    return answer