# 테스트용 코드. 오류는 안 나지만 WebSocket 방식을 사용하는 버전은 아님.
# 코드 실행법: 터미널에 'uvicorn server0:app --reload' 입력 후 새 터미널에 게임 로직 코드 hand_game_logic0.py 를 실행
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

# 임시 저장소 (DB 대신)
game_state = {
    "score": 0,
    "last_label": None
}

# 요청 데이터 구조
class ScoreData(BaseModel):
    """
    클라이언트에서 보내는 데이터 구조

    label: 현재 인식된 제스처 (A, G, N, D)
    score: 현재 게임 점수
    """
    label: str
    score: int


# 1️⃣ 상태 저장 API
@app.post("/update")
def update_score(data: ScoreData):
    game_state["last_label"] = data.label
    game_state["score"] = data.score
    return {"message": "updated", "state": game_state}


# 2️⃣ 상태 조회 API
@app.get("/state")  # "http://127.0.0.1:8000/state" 로컬 서버에서 게임 점수 조회 가능.
def get_state():
    return game_state