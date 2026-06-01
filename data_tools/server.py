from fastapi import FastAPI, WebSocket
import json
import random

app = FastAPI()

clients = []

score = 0
target = "OPEN"
last = "CLOSE"

# 🔥 실패 누적 시스템
fail_count = 0
FAIL_LIMIT = 3   # 3번 틀리면 초기화

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    global score, target, last, fail_count

    await websocket.accept()
    clients.append(websocket)
    print("🟢 connected")

    try:
        while True:
            data = await websocket.receive_text()
            msg = json.loads(data)

            hand = msg.get("hand")

            # 🎯 게임 로직 (안정화 버전)
            if hand == target:
                score += 10
                target = random.choice(["OPEN", "CLOSE"])
                last = hand
                fail_count = 0  # 🔥 성공하면 리셋

            else:
                fail_count += 1

                if fail_count >= FAIL_LIMIT:
                    score = 0
                    fail_count = 0

                last = hand

            game_state = {
                "score": score,
                "target": target,
                "last": last
            }

            for client in clients:
                await client.send_text(json.dumps(game_state))

    except:
        print("🔴 disconnected")
        clients.remove(websocket)