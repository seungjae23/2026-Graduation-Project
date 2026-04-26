import cv2
import mediapipe as mp
import numpy as np
import random
import requests
import time

# =========================
# 1. 서버 설정
# =========================
SERVER_URL = "http://127.0.0.1:8000/update"

def send_to_server(label, score, target):
    try:
        requests.post(SERVER_URL, json={
            "label": label,
            "score": int(score)
        })
        print(f"[SERVER] label={label}, score={score}, target={target}")
    except Exception as e:
        print("[SERVER ERROR]", e)


# =========================
# 2. MediaPipe 설정
# =========================
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)

mp_draw = mp.solutions.drawing_utils


# =========================
# 3. 수어 판정 (간단 룰)
# =========================
def detect_sign(landmarks):
    tips = [8, 12, 16, 20]

    fingers = []
    for tip in tips:
        if landmarks[tip].y < landmarks[tip - 2].y:
            fingers.append(1)
        else:
            fingers.append(0)

    total = sum(fingers)

    if total == 0:
        return "A", 10
    elif total == 1:
        return "G", 20  # ㄱ
    elif total == 2:
        return "N", 30  # ㄴ
    elif total == 3:
        return "D", 40  # ㄷ
    else:
        return "Unknown", 0


# =========================
# 4. 게임 설정
# =========================
SIGN_LIST = ["G", "N", "D"]

score = 0
round_num = 1
target_sign = random.choice(SIGN_LIST)

print("🎮 게임 시작!")
print("현재 문제:", target_sign)


def next_round():
    global target_sign, round_num
    round_num += 1
    target_sign = random.choice(SIGN_LIST)
    print("\n===================")
    print(f"🎯 ROUND {round_num}")
    print("새 문제:", target_sign)


# =========================
# 5. 메인 실행
# =========================
def run():
    global score, target_sign

    cap = cv2.VideoCapture(0)

    last_sent_time = 0

    print("q 누르면 종료")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        result = hands.process(rgb)

        label = "Unknown"
        detected_score = 0

        if result.multi_hand_landmarks:
            for handLms in result.multi_hand_landmarks:

                mp_draw.draw_landmarks(frame, handLms, mp_hands.HAND_CONNECTIONS)

                label, detected_score = detect_sign(handLms.landmark)

                # =========================
                # 6. 정답 체크
                # =========================
                if label == target_sign:
                    score += 10
                    print("✔ 정답! +10점")

                    next_round()
                    time.sleep(0.8)

                # =========================
                # 7. 서버 전송 (0.5초 제한)
                # =========================
                if time.time() - last_sent_time > 0.5:
                    send_to_server(label, score, target_sign)
                    last_sent_time = time.time()

        # =========================
        # 8. 화면 출력
        # =========================
        cv2.putText(frame,
                    f"TARGET: {target_sign}",
                    (30, 40),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (255, 0, 0),
                    2)

        cv2.putText(frame,
                    f"DETECTED: {label}",
                    (30, 80),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (0, 255, 0),
                    2)

        cv2.putText(frame,
                    f"SCORE: {score}",
                    (30, 120),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (0, 255, 255),
                    2)

        cv2.imshow("KSL GAME - ROUND MODE", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()


# =========================
# 9. 실행
# =========================
if __name__ == "__main__":
    run()