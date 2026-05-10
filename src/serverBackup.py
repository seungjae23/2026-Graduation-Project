# 이 코드는 WebSocket 연결하려고 챗지피티랑 수정 진행할거같은 코드
from fastapi import FastAPI, WebSocket
from typing import Dict
import random
import uuid

app = FastAPI()

# =========================
# ROOM 저장소
# =========================
rooms: Dict[str, dict] = {}

SIGN_LIST = ["G", "N", "D"]


# =========================
# ROOM 생성
# =========================
def create_room():
    room_id = str(uuid.uuid4())[:6]

    rooms[room_id] = {
        "players": [],
        "score": 0,
        "target": random.choice(SIGN_LIST),
        "last_label": ""
    }

    return room_id


# =========================
# PLAYER 매칭
# =========================
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    room_id = None
    player_id = None

    # =========================
    # 방 배정
    # =========================
    for rid, room in rooms.items():
        if len(room["players"]) < 2:
            room_id = rid
            break

    if room_id is None:
        room_id = create_room()

    player_id = "P1" if len(rooms[room_id]["players"]) == 0 else "P2"
    rooms[room_id]["players"].append(player_id)

    await websocket.send_json({
        "type": "JOIN",
        "room": room_id,
        "player": player_id
    })

    # =========================
    # 게임 루프
    # =========================
    try:
        while True:
            data = await websocket.receive_json()

            label = data.get("label")

            room = rooms[room_id]

            room["last_label"] = label

            # =========================
            # 정답 체크
            # =========================
            if label == room["target"]:
                room["score"] += 10
                room["target"] = random.choice(SIGN_LIST)

            # =========================
            # 상태 브로드캐스트
            # =========================
            await websocket.send_json({
                "type": "STATE",
                "room": room_id,
                "score": room["score"],
                "target": room["target"],
                "last_label": room["last_label"]
            })

    except:
        room["players"].remove(player_id)