import asyncio
import websockets
import json

async def run_game():
    uri = "ws://127.0.0.1:8000/ws"

    async with websockets.connect(uri) as ws:
        print("🎮 Player1 시작")

        while True:
            action = input("👉 입력 (OPEN / CLOSE): ")

            await ws.send(json.dumps({
                "action": action
            }))

            response = await ws.recv()
            print("📡 SERVER:", response)


if __name__ == "__main__":
    asyncio.run(run_game())