import cv2
import mediapipe as mp
import numpy as np
import joblib
import time
from PIL import ImageFont, ImageDraw, Image

# ===============================
# 🔥 모델 로드
# ===============================
model = joblib.load("hand_model.pkl")

# ===============================
# 🔥 Mediapipe
# ===============================
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    max_num_hands=1,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
)

# ===============================
# 🔥 카메라
# ===============================
cap = cv2.VideoCapture(0)
cap.set(3, 640)
cap.set(4, 480)

# ===============================
# 🔥 폰트
# ===============================
font_path = "C:/Windows/Fonts/malgun.ttf"
font_big = ImageFont.truetype(font_path, 60)
font_mid = ImageFont.truetype(font_path, 30)

# ===============================
# 🔥 텍스트 중앙 출력
# ===============================
def draw_center(frame, text, y, font, color=(255,255,255)):
    img_pil = Image.fromarray(frame)
    draw = ImageDraw.Draw(img_pil)

    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]

    x = (frame.shape[1] - text_w) // 2
    draw.text((x, y), text, font=font, fill=color)

    return np.array(img_pil)

# ===============================
# 🔥 반투명 UI
# ===============================
def draw_ui_box(frame, x1, y1, x2, y2):
    overlay = frame.copy()
    cv2.rectangle(overlay, (x1, y1), (x2, y2), (0, 0, 0), -1)
    return cv2.addWeighted(overlay, 0.4, frame, 0.6, 0)

# ===============================
# 🔥 feature
# ===============================
def extract_features(hand_landmarks):
    data = []
    for lm in hand_landmarks.landmark:
        data.extend([lm.x, lm.y, lm.z])
    return np.array(data)

# ===============================
# 🔥 게임 변수
# ===============================
score = 0
combo = 0
effect_time = 0

start_time = None
game_duration = 30
game_started = False
game_over = False

targets = ["ㄱ", "ㄴ", "ㄷ", "ㄹ"]
current_target = np.random.choice(targets)

# ===============================
# 🔥 메인 루프
# ===============================
while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)
    h, w, _ = frame.shape

    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    result = hands.process(rgb)

    predicted_char = "?"

    # ===============================
    # 🔥 손 인식
    # ===============================
    if result.multi_hand_landmarks:
        for hand_landmarks in result.multi_hand_landmarks:
            features = extract_features(hand_landmarks).reshape(1, -1)

            try:
                predicted_char = model.predict(features)[0]
            except:
                predicted_char = "?"

    # ===============================
    # 🔥 시작 화면
    # ===============================
    if not game_started:
        frame = draw_center(frame, "S를 눌러 시작", int(h*0.45), font_big)

        key = cv2.waitKey(1)
        if key == ord('s'):
            game_started = True
            start_time = time.time()

    # ===============================
    # 🔥 게임 진행
    # ===============================
    elif not game_over:
        elapsed = time.time() - start_time
        remaining = int(game_duration - elapsed)

        if remaining <= 0:
            game_over = True

        frame = draw_ui_box(frame, 0, 0, w, 120)

        # UI 텍스트
        frame = draw_center(frame, f"목표: {current_target}", 10, font_mid)
        frame = draw_center(frame, f"내 동작: {predicted_char}", 50, font_mid)

        cv2.putText(frame, f"Score: {score}", (20, 40),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)

        cv2.putText(frame, f"Combo: {combo}", (20, 80),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0,200,255), 2)

        cv2.putText(frame, f"Time: {remaining}", (w-180, 40),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 2)

        # ===============================
        # 🔥 정답 판정
        # ===============================
        if predicted_char == current_target:
            combo += 1
            score += 10 + combo * 2
            current_target = np.random.choice(targets)

            effect_time = time.time()
            time.sleep(0.3)

        else:
            combo = 0

        # ===============================
        # 🔥 이펙트 (번쩍)
        # ===============================
        if time.time() - effect_time < 0.2:
            flash = np.ones_like(frame, dtype=np.uint8) * 255
            frame = cv2.addWeighted(frame, 0.7, flash, 0.3, 0)

        # ===============================
        # 🔥 콤보 텍스트
        # ===============================
        if combo >= 2:
            frame = draw_center(frame, f"{combo} COMBO!", int(h*0.75), font_big, (0,255,255))

    # ===============================
    # 🔥 게임 종료
    # ===============================
    else:
        frame = draw_center(frame, "게임 종료!", int(h*0.3), font_big)
        frame = draw_center(frame, f"최종 점수: {score}", int(h*0.5), font_big)

    cv2.imshow("Hand Game", frame)

    key = cv2.waitKey(1)
    if key == 27:
        break

cap.release()
cv2.destroyAllWindows()