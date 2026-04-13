from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import mediapipe as mp
import numpy as np
import cv2
import time
import csv
import os

from mediapipe.tasks import python
from mediapipe.tasks.python import vision

app = FastAPI()

# ==========================================
# 🎯 [설정] 현재 수집할 수어 라벨을 여기에 적으세요!
# ㄱ을 수집할 때는 "ㄱ"으로, ㄴ을 수집할 때는 "ㄴ"으로 변경 후 서버 재시작
TARGET_LABEL = "ㄱ"  
CSV_FILE_NAME = "hand_data.csv"
# ==========================================

# 1. MediaPipe 설정
base_options = python.BaseOptions(model_asset_path='hand_landmarker.task')
options = vision.HandLandmarkerOptions(
    base_options=base_options,
    running_mode=vision.RunningMode.VIDEO,
    num_hands=1
)
detector = vision.HandLandmarker.create_from_options(options)

# 2. 데이터 추출 함수 추가
def extract_coordinates(landmarks):
    """21개의 랜드마크에서 x, y, z 값을 추출하여 1차원 배열로 만듭니다."""
    row = []
    for lm in landmarks:
        row.extend([lm.x, lm.y, lm.z]) # 총 63개의 값
    return row

@app.get("/")
async def root():
    return {"status": "Server is running!"}

@app.websocket("/ws/sign-language")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    print("✅ 클라이언트 연결됨. 데이터 수집을 시작합니다...")
    
    # CSV 파일이 없으면 헤더(칼럼명)를 먼저 만들어줍니다.
    if not os.path.exists(CSV_FILE_NAME):
        with open(CSV_FILE_NAME, mode='w', newline='', encoding='utf-8-sig') as f:
            writer = csv.writer(f)
            # x0, y0, z0, x1, y1, z1 ... x20, y20, z20, label
            header = []
            for i in range(21):
                header.extend([f'x{i}', f'y{i}', f'z{i}'])
            header.append('label')
            writer.writerow(header)

    try:
        while True:
            data = await websocket.receive_bytes()
            nparr = np.frombuffer(data, np.uint8)
            frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if frame is not None:
                mp_image = mp.Image(
                    image_format=mp.ImageFormat.SRGB, 
                    data=cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                )
                
                frame_timestamp_ms = int(time.time() * 1000)
                res = detector.detect_for_video(mp_image, frame_timestamp_ms)
                
                if res.hand_landmarks:
                    # 💡 [핵심] 랜드마크 추출 및 CSV 저장
                    row = extract_coordinates(res.hand_landmarks[0])
                    row.append(TARGET_LABEL) # 배열 맨 끝에 정답("ㄱ") 추가
                    
                    with open(CSV_FILE_NAME, mode='a', newline='', encoding='utf-8-sig') as f:
                        writer = csv.writer(f)
                        writer.writerow(row)
                    
                    # 클라이언트 화면에는 수집 중인 라벨을 보여줍니다.
                    await websocket.send_json({"label": f"[수집중] {TARGET_LABEL}"})
                else:
                    await websocket.send_json({"label": "손을 보여주세요"})
            else:
                await websocket.send_json({"label": "Error"})

    except WebSocketDisconnect:
        print("❌ 클라이언트 연결 종료.")
    except Exception as e:
        print(f"⚠️ 에러 발생: {e}")

@app.on_event("shutdown")
def shutdown_event():
    detector.close()
