import cv2
import mediapipe as mp
import csv
import time
import os
import numpy as np
# 예시용 TensorFlow 모델 불러오기
from tensorflow.keras.models import load_model

# ---------------------------
# mediapipe 세팅
# ---------------------------
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,  # AI 모델 예측용으로 1손만
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7
)
mp_draw = mp.solutions.drawing_utils

# ---------------------------
# AI 모델 로드 (예시)
# ---------------------------
# hand_gesture_model.h5 는 미리 학습된 모델 파일
model_path = "hand_gesture_model.h5"
if os.path.exists(model_path):
    model = load_model(model_path)
else:
    model = None
    print("⚠️ 모델 파일이 없습니다. 예측 기능은 비활성화 됩니다.")

# ---------------------------
# CSV 저장 준비
# ---------------------------
output_dir = "hand_data"
os.makedirs(output_dir, exist_ok=True)
timestamp = int(time.time())
csv_file = os.path.join(output_dir, f"hand_landmarks_{timestamp}.csv")

# CSV 헤더 생성
header = ["frame"]
for i in range(21):
    header += [f"x{i}", f"y{i}", f"z{i}"]
header += ["prediction"]  # AI 예측값

with open(csv_file, mode="w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(header)

# ---------------------------
# 카메라 열기
# ---------------------------
cap = cv2.VideoCapture(0)
frame_count = 0

while True:
    ret, frame = cap.read()
    if not ret:
        break

    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(rgb_frame)

    row = [frame_count]
    coords = []

    if results.multi_hand_landmarks:
        hand_landmarks = results.multi_hand_landmarks[0]  # 1손만
        for lm in hand_landmarks.landmark:
            coords += [lm.x, lm.y, lm.z]
        mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

        # AI 예측
        if model:
            X = np.array(coords).reshape(1, 63)  # 모델 입력 크기 맞춤
            pred = np.argmax(model.predict(X, verbose=0), axis=1)[0]
        else:
            pred = None
    else:
        coords += [None]*63
        pred = None

    row += coords
    row += [pred]

    # CSV 저장
    with open(csv_file, mode="a", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(row)

    frame_count += 1

    # 화면에 예측 텍스트 표시
    if pred is not None:
        cv2.putText(frame, f"Prediction: {pred}", (10,50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 2)

    cv2.imshow("Hand Tracking AI", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
print(f"Data saved to {csv_file}")