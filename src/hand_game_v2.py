import cv2
import numpy as np
import mediapipe as mp
from PIL import ImageFont, ImageDraw, Image
import random
import time

# MediaPipe 설정
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)
mp_draw = mp.solutions.drawing_utils

# --- 거리 계산 ---
def get_distance(p1, p2):
    return np.linalg.norm(np.array(p1) - np.array(p2))

# --- KSL 문자 인식 (업그레이드 버전) ---
def classify_ksl(lm_list):
    wrist = lm_list[0]
    tips = [8, 12, 16, 20]

    fingers = []

    for tip in tips:
        dist = get_distance(lm_list[tip], wrist)

        if dist > 120:   # 필요하면 80~150 사이 조정
            fingers.append(1)
        else:
            fingers.append(0)

    count = sum(fingers)

    if count == 0:
        return "ㅁ"
    elif count == 1:
        return "ㄴ"
    elif count == 2:
        return "ㄷ"
    elif count == 3:
        return "ㅂ"
    elif count == 4:
        return "ㅎ"
    else:
        return "Unknown"

# --- 게임 설정 ---
problems = ["ㄴ", "ㄷ", "ㅁ", "ㅂ", "ㅎ"]
current_problem = random.choice(problems)
score_total = 0
start_time = time.time()
TIME_LIMIT = 5

# --- 메인 ---
def run():
    global current_problem, score_total, start_time

    cap = cv2.VideoCapture(0)
    print("게임 시작! q 누르면 종료")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)
        h, w, _ = frame.shape

        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        result = hands.process(rgb)

        label = "Unknown"

        if result.multi_hand_landmarks:
            for handLms in result.multi_hand_landmarks:
                lm_list = []

                for lm in handLms.landmark:
                    lm_list.append((lm.x * w, lm.y * h))

                label = classify_ksl(lm_list)
                mp_draw.draw_landmarks(frame, handLms, mp_hands.HAND_CONNECTIONS)

        # --- 정답 체크 ---
        if label == current_problem:
            score_total += 10
            current_problem = random.choice(problems)
            start_time = time.time()

        # --- 시간 초과 ---
        if time.time() - start_time > TIME_LIMIT:
            current_problem = random.choice(problems)
            start_time = time.time()

        # --- 남은 시간 ---
        remaining_time = int(TIME_LIMIT - (time.time() - start_time))
        if remaining_time < 0:
            remaining_time = 0

        # --- 화면 출력 ---
        pil_img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
        draw = ImageDraw.Draw(pil_img)
        font = ImageFont.truetype("C:/Windows/Fonts/malgun.ttf", 40)

        draw.text((30, 30), f"문제: {current_problem}", font=font, fill=(255,255,0))
        draw.text((30, 90), f"Detected: {label}", font=font, fill=(0,255,0))
        draw.text((30, 150), f"Score: {score_total}", font=font, fill=(0,255,255))
        draw.text((30, 210), f"Time: {remaining_time}", font=font, fill=(255,0,0))

        frame = cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)

        cv2.imshow("KSL Game v2", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    run()