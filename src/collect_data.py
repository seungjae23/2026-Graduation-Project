import cv2
import mediapipe as mp
import csv
import os
import numpy as np

from PIL import ImageFont, ImageDraw, Image

# =========================
# 👉 한글 폰트 설정
# =========================
font_path = "C:/Windows/Fonts/malgun.ttf"
font = ImageFont.truetype(font_path, 25)

def draw_korean(frame, text, pos, color=(0,255,0)):
    img_pil = Image.fromarray(frame)
    draw = ImageDraw.Draw(img_pil)
    draw.text(pos, text, font=font, fill=color)
    return np.array(img_pil)

# =========================
# MediaPipe 설정
# =========================
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils

# =========================
# 저장 파일
# =========================
file_name = "hand_data.csv"

if not os.path.exists(file_name):
    with open(file_name, mode='w', newline='') as f:
        writer = csv.writer(f)
        header = []
        for i in range(21):
            header += [f'x{i}', f'y{i}', f'z{i}']
        header.append("label")
        writer.writerow(header)

current_label = None

# =========================
# 카메라 시작
# =========================
cap = cv2.VideoCapture(0)

with mp_hands.Hands(max_num_hands=1) as hands:
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        result = hands.process(rgb)

        landmarks_data = None

        # =========================
        # 손 인식
        # =========================
        if result.multi_hand_landmarks:
            for hand_landmarks in result.multi_hand_landmarks:
                mp_drawing.draw_landmarks(
                    frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

                landmarks_data = []
                for lm in hand_landmarks.landmark:
                    landmarks_data.extend([lm.x, lm.y, lm.z])

        # =========================
        # 👉 화면 크기 가져오기
        # =========================
        h, w, _ = frame.shape

        # =========================
        # 👉 UI (한글, 안 잘림)
        # =========================
        if current_label:
            frame = draw_korean(frame, f"라벨: {current_label}", (20, 40))

        frame = draw_korean(
            frame,
            "g:ㄱ n:ㄴ d:ㄷ r:ㄹ | s:저장 q:종료",
            (20, h - 30),   # 👉 핵심: 화면 기준 위치
            (255,255,255)
        )

        cv2.imshow("Collect Data", frame)

        key = cv2.waitKey(1) & 0xFF

        # =========================
        # 👉 라벨 선택
        # =========================
        if key == ord('g'):
            current_label = "ㄱ"
            print("👉 ㄱ 선택")

        elif key == ord('n'):
            current_label = "ㄴ"
            print("👉 ㄴ 선택")

        elif key == ord('d'):
            current_label = "ㄷ"
            print("👉 ㄷ 선택")

        elif key == ord('r'):
            current_label = "ㄹ"
            print("👉 ㄹ 선택")

        # =========================
        # 👉 데이터 저장
        # =========================
        elif key == ord('s'):
            if landmarks_data and current_label:
                with open(file_name, mode='a', newline='') as f:
                    writer = csv.writer(f)
                    writer.writerow(landmarks_data + [current_label])
                print(f"✅ 저장됨: {current_label}")
            else:
                print("❌ 손 or 라벨 없음")

        # =========================
        # 종료
        # =========================
        elif key == ord('q'):
            break

# =========================
# 종료 처리
# =========================
cap.release()
cv2.destroyAllWindows()