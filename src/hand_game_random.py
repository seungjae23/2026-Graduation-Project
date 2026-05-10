import asyncio
import websockets
import json
import random
import time

SERVER_URL = "ws://127.0.0.1:8000/ws"

async def bot():
    async with websockets.connect(SERVER_URL) as websocket:
        print("🤖 Player2 BOT 시작")

        while True:
            hand = random.choice(["OPEN", "CLOSE"])
            await websocket.send(json.dumps({"hand": hand}))

            data = await websocket.recv()
            game_state = json.loads(data)

            print("[BOT]", game_state)

            time.sleep(1.0)  # 🔥 속도 맞춤

asyncio.run(bot())