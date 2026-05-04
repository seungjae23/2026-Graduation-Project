"""
OpenSign 퀴즈 백엔드(FastAPI) 메인 모듈

목적 :
- 프론트엔드에서 전달한 90프레임(base64 PNG) 시퀀스를 입력받아, GRU(v2) 모델로 수어 단어를 예측한다.
- 카테고리별 라벨 목록 조회 API를 제공한다.
- 서버 시작 시 모델을 미리 로드하여 요청마다 재로드하지 않는다(캐싱).

입력 형식 :
- /predict : JSON { category: 문자열, frames: 길이 90의 base64 PNG 리스트 }
- /labels : 쿼리스트링 category=카테고리명

출력 형식 :
- /predict : { label: 문자열, prob: 0~1 실수(소수 4자리) }
- /labels : [라벨 문자열...]
"""

import os
import io
import base64
import pickle
import torch
import numpy as np
from PIL import Image
from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import mediapipe as mp
import logging

from model_v2 import KeypointGRUModelV2

logger = logging.getLogger(__name__)

# ───── 기본 설정 ─────
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models")
FRAME_TARGET = 90

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ───── 모델/라벨맵 캐시 ─────
model_cache = {}
label_map_cache = {}

# ───── Mediapipe 설정 ─────
mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(static_image_mode=True, model_complexity=1, min_detection_confidence=0.5)

# ───── 서버 시작 시 모델 로드 ─────
@app.on_event("startup")
def load_all_models():
    for category in ["가족", "시간"]:
        model_path = os.path.join(MODEL_DIR, f"{category}_model.pth")
        label_path = os.path.join(MODEL_DIR, f"{category}_label_map.pkl")

        if not os.path.exists(model_path) or not os.path.exists(label_path):
            logger.warning(f"모델 파일 없음: {category}")
            continue

        with open(label_path, "rb") as f:
            label_map = pickle.load(f)
        label_map_cache[category] = label_map

        model = KeypointGRUModelV2(input_dim=152, attn_dim=146, num_classes=len(label_map)).to(DEVICE)
        model.load_state_dict(torch.load(model_path, map_location=DEVICE))
        model.eval()
        model_cache[category] = model
        logger.info(f"모델 로드 완료: {category}")

# ───── 입력 데이터 모델 ─────
class PredictRequest(BaseModel):
    category: str
    frames: List[str]  # base64 PNG 90장

# ───── /labels API ─────
@app.get("/labels")
def get_labels(category: str = Query(...)):
    label_map = label_map_cache.get(category)
    if not label_map:
        raise HTTPException(status_code=404, detail=f"카테고리 '{category}' 라벨맵 없음")
    labels = [k for k, _ in sorted(label_map.items(), key=lambda x: x[1])]
    return labels

# ───── 특징 추출 함수 ─────
def calculate_relative_hand_coords(hand_kpts):
    if np.all(hand_kpts == 0): return hand_kpts
    return hand_kpts - hand_kpts[0]

def calculate_finger_angles(hand_kpts):
    if np.all(hand_kpts == 0): return np.zeros(10)
    angles = []
    fingers = {'thumb':[1,2,3,4], 'index':[5,6,7,8], 'middle':[9,10,11,12], 'ring':[13,14,15,16], 'pinky':[17,18,19,20]}
    for joints in fingers.values():
        for i in range(len(joints)-2):
            a, b, c = hand_kpts[joints[i]], hand_kpts[joints[i+1]], hand_kpts[joints[i+2]]
            v1, v2 = a - b, c - b
            cos = np.dot(v1, v2) / (np.linalg.norm(v1)*np.linalg.norm(v2)+1e-6)
            angles.append(np.arccos(np.clip(cos, -1.0, 1.0)))
    return np.array(angles)

def calculate_hand_face_relation(lh, rh, face):
    nose = face[1] if np.any(face) else np.zeros(3)
    lw = lh[0] if np.any(lh) else np.zeros(3)
    rw = rh[0] if np.any(rh) else np.zeros(3)
    return np.concatenate([lw - nose, rw - nose])

def extract_feature(image_np):
    results = holistic.process(image_np)
    if not results.left_hand_landmarks and not results.right_hand_landmarks:
        logger.warning("손 랜드마크 미검출 — 해당 프레임 zeros로 채움")
    face = np.array([[l.x,l.y,l.z] for l in results.face_landmarks.landmark]) if results.face_landmarks else np.zeros((468,3))
    lh = np.array([[l.x,l.y,l.z] for l in results.left_hand_landmarks.landmark]) if results.left_hand_landmarks else np.zeros((21,3))
    rh = np.array([[l.x,l.y,l.z] for l in results.right_hand_landmarks.landmark]) if results.right_hand_landmarks else np.zeros((21,3))

    rel_lh = calculate_relative_hand_coords(lh).flatten()
    rel_rh = calculate_relative_hand_coords(rh).flatten()
    angles_lh = calculate_finger_angles(lh)
    angles_rh = calculate_finger_angles(rh)
    rel_feat = calculate_hand_face_relation(lh, rh, face)

    return np.concatenate([rel_lh, rel_rh, angles_lh, angles_rh, rel_feat])

# ───── /predict API ─────
@app.post("/predict")
def predict(req: PredictRequest):
    if req.category not in model_cache:
        raise HTTPException(status_code=404, detail=f"지원하지 않는 카테고리: {req.category}")
    if len(req.frames) != FRAME_TARGET:
        raise HTTPException(status_code=422, detail=f"프레임 수 오류: {len(req.frames)}개 (90 필요)")

    model = model_cache[req.category]
    label_map = label_map_cache[req.category]
    idx_to_label = {v: k for k, v in label_map.items()}

    sequence = []
    for i, frame_b64 in enumerate(req.frames):
        try:
            raw = frame_b64.split(",")[1] if "," in frame_b64 else frame_b64
            image = Image.open(io.BytesIO(base64.b64decode(raw))).convert("RGB")
            feature = extract_feature(np.array(image))
        except Exception as e:
            raise HTTPException(status_code=422, detail=f"프레임 {i} 파싱 오류: {e}")
        sequence.append(feature)

    x = torch.tensor(np.array(sequence), dtype=torch.float32).unsqueeze(0).to(DEVICE)
    with torch.no_grad():
        prob = torch.softmax(model(x), dim=-1)
        top = torch.argmax(prob, dim=-1).item()

    return {"label": idx_to_label[top], "prob": round(prob[0, top].item(), 4)}

# ───── 앱 실행 ─────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
