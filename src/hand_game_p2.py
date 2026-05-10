import asyncio
import websockets
import json
import random

actions = ["OPEN", "CLOSE"]

async def bot():
    uri = "ws://127.0.0.1:8000/ws"

    async with websockets.connect(uri) as ws:
        print("🤖 Player2 BOT 시작")

        while True:
            action = random.choice(actions)

            await ws.send(json.dumps({
                "action": action
            }))

            response = await ws.recv()
            print("[BOT]", response)

            await asyncio.sleep(1)


if __name__ == "__main__":
    asyncio.run(bot())