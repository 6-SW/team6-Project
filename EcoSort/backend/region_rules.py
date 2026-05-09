FALLBACK_GUIDE = {
    "disposal_steps": ["종량제 봉투에 담아 배출"],
    "disposal_notes": ["재활용 불가 품목은 종량제 봉투로 처리"]
}

# 광주 동구 공통 배출 정보 (CSV 데이터 반영)
DONGGU_COMMON_INFO = {
    "location": "집 앞 (문전수거)",
    "schedule": "매일 배출"
}

RULES = {
    "gwangju_dong": {
        "pet": {
            "disposal_steps": [
                "내용물을 완전히 비우기",
                "물로 헹구기",
                "라벨(비닐 스티커) 제거 후 비닐류로 별도 배출",
                "압착 후 뚜껑 닫기",
                "투명 페트병은 일반 플라스틱과 분리하여 별도 배출",
                "투명한 비닐봉투에 담아 배출 (동구청 지침)" # CSV 반영
            ],
            "disposal_notes": [
                "광주 동구는 투명 페트병 별도 분리배출 대상",
                "이물질 묻은 경우 종량제 봉투에 배출",
                "색깔 있는 페트병은 일반 플라스틱으로 배출"
            ],
        },
        "plastic": {
            "disposal_steps": [
                "내용물 비우기",
                "이물질 제거 후 헹구기",
                "재질별로 투명한 비닐봉투에 담아 배출 (동구청 지침)" # CSV 반영
            ],
            "disposal_notes": [
                "컵라면 용기, 과일망, 보냉팩은 종량제 봉투에 배출",
                "오염이 심한 경우 종량제 봉투에 배출"
            ],
        },
        "glass": {
            "disposal_steps": [
                "내용물 비우기",
                "물로 헹구기",
                "투명한 비닐봉투에 담아 배출 (동구청 지침)" # CSV 반영
            ],
            "disposal_notes": [
                "깨진 유리는 신문지에 싸서 종량제 봉투에 배출",
                "판유리, 조명기구용 유리는 재활용 불가 — 종량제 봉투 배출"
            ],
        },
        "can": {
            "disposal_steps": [
                "내용물 비우기",
                "물로 헹구기",
                "가능하면 압착 후 투명한 비닐봉투에 담아 배출 (동구청 지침)" # CSV 반영
            ],
            "disposal_notes": [
                "페인트·락카 등 내용물 남은 캔은 종량제 봉투에 배출",
                "부탄가스 캔은 통풍 잘 되는 곳에서 구멍 뚫어 배출"
            ],
        },
        "paper": {
            "disposal_steps": [
                "물기 없는 상태로 끈으로 묶거나 박스에 담아 배출 (동구청 지침)", # CSV 반영
                "비닐 코팅 표지·스프링 제거 후 배출"
            ],
            "disposal_notes": [
                "음식물 묻은 종이는 종량제 봉투에 배출",
                "종이팩(우유팩)은 일반 종이류와 구분하여 별도 배출"
            ],
        },
        "vinyl": {
            "disposal_steps": [
                "이물질 제거 후 투명봉투에 모아 배출 (동구청 지침)", # CSV 반영
                "부피 줄여 접어서 배출"
            ],
            "disposal_notes": [
                "음식물·스티커 등 이물질 있는 비닐은 종량제 봉투에 배출",
                "은박 비닐은 종량제 봉투에 배출"
            ],
        },
        "food": {
            "disposal_steps": [
                "물기를 최대한 줄이기 (동구청 지침)", # CSV 반영
                "이물질(비닐, 뼈, 조개류 등) 제거",
                "음식물 전용 용기에 담아 배출 (동구청 지침)" # CSV 반영
            ],
            "disposal_notes": [
                "코코넛·밤·파인애플 등 딱딱한 껍데기는 일반쓰레기",
                "뼈, 조개껍데기는 음식물 쓰레기 제외 — 종량제 봉투"
            ],
        },
        "general": {
            "disposal_steps": [
                "종량제 봉투에 담아서 매일 배출 (동구청 지침)" # CSV 반영
            ],
            "disposal_notes": [
                "재활용 불가 품목은 종량제 봉투로 처리"
            ]
        },
    },
}

def resolve_region(lat: float, lon: float) -> str:
    # TODO: 추후 광주광역시 다른 구(서구, 남구 등) 좌표 경계선 추가
    if 35.13 <= lat <= 35.17 and 126.90 <= lon <= 126.95:
        return "gwangju_dong"
    return "gwangju_dong"  # 중간발표용 기본값 세팅

def get_disposal_guide(category: str, lat: float, lon: float) -> dict:
    region = resolve_region(lat, lon)
    region_rule = RULES.get(region, {})
    
    # 1. 해당 지역의 카테고리별 규정 가져오기 (없으면 Fallback)
    guide = region_rule.get(category, FALLBACK_GUIDE)
    
    # 2. 광주 동구일 경우, 배출 장소와 요일 같은 공통 메타데이터를 결과에 병합하여 반환
    result = {"region": region, **guide}
    
    if region == "gwangju_dong":
        result.update(DONGGU_COMMON_INFO)
        
    return result

# --- 테스트 코드 ---
# guide = get_disposal_guide("pet", 35.15, 126.92)
# print(guide)

