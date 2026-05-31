import os
import json
import requests
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(dotenv_path=Path(__file__).resolve().parent.parent / ".env")

KAKAO_API_KEY = os.getenv("KAKAO_API_KEY")

# region_disposal.json 로드
DATA_PATH = Path(__file__).resolve().parent / "region_disposal.json"
with open(DATA_PATH, encoding='utf-8') as f:
    REGION_DATA = json.load(f)

FALLBACK_GUIDE = {
    "region": "알 수 없는 지역",
    "disposal_steps": ["종량제 봉투에 담아 배출"],
    "disposal_notes": ["지역 기준이 다를 수 있으니 지자체 홈페이지를 확인하세요"],
    "location": "집 앞",
    "schedule": "지자체 기준 확인 필요"
}

def get_region_from_coords(lat: float, lon: float) -> tuple:
    try:
        url = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json"
        headers = {"Authorization": f"KakaoAK {KAKAO_API_KEY}"}
        params = {"x": lon, "y": lat}
        response = requests.get(url, headers=headers, params=params, timeout=5)
        data = response.json()

        if data.get("documents"):
            doc = data["documents"][0]
            sido = doc.get("region_1depth_name", "")
            sigungu = doc.get("region_2depth_name", "")
            return sido, sigungu
    except Exception as e:
        print(f"카카오 API 오류: {e}")
    return "", ""

def get_disposal_guide(category: str, lat: float, lon: float) -> dict:
    sido, sigungu = get_region_from_coords(lat, lon)
    
    region_info = None
    if sido and sigungu:
        sido_data = REGION_DATA.get(sido, {})
        region_info = sido_data.get(sigungu)
        
        # 시군구 직접 매칭 안되면 부분 매칭 시도
        if not region_info:
            for key in sido_data:
                if sigungu in key or key in sigungu:
                    region_info = sido_data[key]
                    break

    if not region_info:
        return FALLBACK_GUIDE

    return {
        "region": f"{sido} {sigungu}",
        "disposal_steps": [
            f"생활쓰레기: {region_info['생활쓰레기배출방법']}",
            f"음식물쓰레기: {region_info['음식물쓰레기배출방법']}",
            f"재활용품: {region_info['재활용품배출방법']}",
        ],
        "disposal_notes": [
            f"생활쓰레기 배출요일: {region_info['생활쓰레기배출요일']}",
            f"배출시간: {region_info['생활쓰레기배출시간']}",
            f"미수거일: {region_info['미수거일']}",
            f"문의: {region_info['관리부서']} {region_info['관리부서전화']}",
        ],
        "location": region_info['배출장소'],
        "schedule": region_info['생활쓰레기배출요일'],
    }