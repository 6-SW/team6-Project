WASTE_CATEGORY_CATALOG = {
    "pet": {
        "label": "페트병",
        "aliases": ["페트병", "투명페트병", "PET", "PET병"],
        "items": ["생수병", "음료수병", "탄산음료 페트병", "주스 페트병"],
        "default_steps": [
            "내용물을 완전히 비운다.",
            "라벨과 뚜껑을 분리한다.",
            "가볍게 헹군 뒤 압착해서 배출한다.",
        ],
        "default_notes": [
            "투명 페트병은 지역 기준에 따라 별도 분리배출 대상일 수 있다.",
            "오염이 심하면 세척 후 배출하거나 지자체 기준을 확인한다.",
        ],
    },
    "plastic": {
        "label": "플라스틱",
        "aliases": ["플라스틱", "플라스틱류"],
        "items": ["샴푸통", "세제통", "플라스틱 반찬통", "요거트 용기"],
        "default_steps": [
            "내용물을 비우고 이물질을 제거한다.",
            "가능하면 물로 헹군다.",
            "같은 재질끼리 모아 배출한다.",
        ],
        "default_notes": [
            "심하게 오염된 플라스틱은 일반쓰레기로 처리될 수 있다.",
        ],
    },
    "glass": {
        "label": "유리병",
        "aliases": ["유리병", "유리", "병"],
        "items": ["소주병", "맥주병", "잼병", "유리 음료병"],
        "default_steps": [
            "내용물을 비운다.",
            "뚜껑이나 다른 재질 부착물을 분리한다.",
            "유리병 수거 기준에 맞게 배출한다.",
        ],
        "default_notes": [
            "깨진 유리는 재활용이 어렵기 때문에 안전하게 감싸 일반쓰레기로 배출한다.",
        ],
    },
    "can": {
        "label": "캔",
        "aliases": ["캔", "금속", "고철", "알루미늄캔"],
        "items": ["음료 캔", "맥주 캔", "통조림 캔", "철캔"],
        "default_steps": [
            "내용물을 비운다.",
            "물로 헹군다.",
            "가능하면 압착해서 배출한다.",
        ],
        "default_notes": [
            "가스가 남은 캔은 안전하게 배출해야 한다.",
        ],
    },
    "paper": {
        "label": "종이",
        "aliases": ["종이", "종이류", "박스", "상자"],
        "items": ["신문지", "택배박스", "종이 쇼핑백", "책자"],
        "default_steps": [
            "테이프, 비닐, 스프링 같은 이물질을 제거한다.",
            "젖지 않게 모아서 묶어 배출한다.",
        ],
        "default_notes": [
            "음식물이나 기름이 묻은 종이는 일반쓰레기로 분류될 수 있다.",
        ],
    },
    "vinyl": {
        "label": "비닐",
        "aliases": ["비닐", "비닐류", "봉투", "랩"],
        "items": ["과자봉지", "비닐봉투", "포장비닐", "랩"],
        "default_steps": [
            "내용물을 비우고 이물질을 제거한다.",
            "가능하면 간단히 세척한다.",
            "비닐류로 따로 모아 배출한다.",
        ],
        "default_notes": [
            "오염된 비닐은 세척 후에도 재활용이 어렵다면 일반쓰레기로 처리한다.",
        ],
    },
    "food": {
        "label": "음식물",
        "aliases": ["음식물", "음식물쓰레기", "잔반"],
        "items": ["남은 음식", "과일 껍질", "채소 찌꺼기", "밥"],
        "default_steps": [
            "물기를 최대한 제거한다.",
            "음식물 전용 수거함 또는 전용 봉투에 담는다.",
            "이물질을 분리한 뒤 배출한다.",
        ],
        "default_notes": [
            "뼈, 조개껍데기, 씨앗 같은 단단한 물질은 일반쓰레기로 분리해야 한다.",
        ],
    },
    "general": {
        "label": "일반쓰레기",
        "aliases": ["일반쓰레기", "일반", "종량제"],
        "items": ["휴지", "오염된 플라스틱", "깨진 도자기", "담배꽁초"],
        "default_steps": [
            "재활용이 어려운 품목은 종량제 봉투에 담는다.",
            "날카롭거나 위험한 것은 안전하게 감싸 배출한다.",
        ],
        "default_notes": [
            "재활용 가능 여부가 애매하면 지자체 기준을 확인한다.",
        ],
    },
}


def build_category_prompt() -> str:
    category_lines = []
    for entry in WASTE_CATEGORY_CATALOG.values():
        sample_items = ", ".join(entry["items"])
        category_lines.append(f"- {entry['label']}: {sample_items}")

    category_guide = "\n".join(category_lines)
    return (
        "이 이미지의 폐기물을 아래 카테고리 중 하나로 분류해줘.\n"
        "반드시 카테고리 이름만 답해줘.\n"
        f"{category_guide}"
    )


def normalize_category_key(category_input: str) -> tuple[str, str]:
    compact = category_input.strip().lower().replace(" ", "")

    for category_key, entry in WASTE_CATEGORY_CATALOG.items():
        candidates = [category_key, entry["label"], *entry["aliases"], *entry["items"]]
        for candidate in candidates:
            if candidate.lower().replace(" ", "") == compact:
                return entry["label"], category_key

    fallback = WASTE_CATEGORY_CATALOG["general"]
    return fallback["label"], "general"


def build_selected_category_prompt(category_key: str) -> str:
    entry = WASTE_CATEGORY_CATALOG[category_key]
    sample_items = ", ".join(entry["items"])
    default_steps = "\n".join(f"- {step}" for step in entry["default_steps"])
    default_notes = "\n".join(f"- {note}" for note in entry["default_notes"])

    return (
        f"사용자는 '{entry['label']}' 카테고리를 직접 선택했다.\n"
        "이미지 속 물체를 이 카테고리 기준으로 확인해서 현재 상태에 맞는 분리배출 방법을 판단해줘.\n"
        "특히 세척 필요 여부, 라벨 제거 필요 여부, 뚜껑 분리 필요 여부, 압착 필요 여부, 오염 여부를 반영해줘.\n"
        "반드시 아래 JSON 형식으로만 답해줘.\n"
        '{"item_name":"카테고리명","disposal_steps":["문장1","문장2"],"disposal_notes":["문장1","문장2"]}\n'
        f"카테고리 예시 품목:\n- {entry['label']}: {sample_items}\n"
        f"기본 배출 단계 참고:\n{default_steps}\n"
        f"기본 주의사항 참고:\n{default_notes}"
    )


def normalize_category_answer(answer: str) -> tuple[str, str]:
    compact = answer.strip().lower().replace(" ", "")

    for category_key, entry in WASTE_CATEGORY_CATALOG.items():
        for alias in [*entry["aliases"], *entry["items"]]:
            if alias.lower().replace(" ", "") in compact:
                return entry["label"], category_key

    fallback = WASTE_CATEGORY_CATALOG["general"]
    return fallback["label"], "general"
