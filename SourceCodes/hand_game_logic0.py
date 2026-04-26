# 간단한 게임 로직 테스트용 코드. WebSocket 방식을 사용하는 버전은 아님.
# 먼저 server0.py를 실행한 후 이 코드 실행.
# 코드 실행법: 터미널에 'uvicorn server0:app --reload' 입력 후 새 터미널에 hand_game_logic0.py 실행
# "http://127.0.0.1:8000/state" 로컬 서버에 게임 점수가 전달됨.
import cv2
import mediapipe as mp
import random
import time
import requests

# =========================
# 서버 설정
# =========================
SERVER_URL = "http://127.0.0.1:8000/update"  

def send_to_server(label, score, target, status):
    try:
        requests.post(SERVER_URL, json={
            "label": label,
            "score": int(score),
            "status": status
        })
    except:
        pass


# =========================
# MediaPipe
# =========================
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)
mp_draw = mp.solutions.drawing_utils


# =========================
# 수어 판정
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
        return "A"
    elif total == 1:
        return "G"
    elif total == 2:
        return "N"
    elif total == 3:
        return "D"
    else:
        return "Unknown"


# =========================
# 게임 설정
# =========================
SIGN_LIST = ["G", "N", "D"]
GAME_TIME = 60
COOLDOWN = 1.2

score = 0
target_sign = random.choice(SIGN_LIST)

game_started = False
game_over = False

last_correct_time = 0
start_time = 0


# =========================
# 다음 라운드
# =========================
def next_round():
    global target_sign
    target_sign = random.choice(SIGN_LIST)


# =========================
# 메인
# =========================
def run():
    global score, game_started, game_over, last_correct_time, start_time

    cap = cv2.VideoCapture(0)

    # 👉 창 안정화 (중요)
    cv2.namedWindow("KSL GAME FINAL", cv2.WINDOW_NORMAL)

    print("🎮 준비 완료")
    print("SPACE: 시작 / Q or ESC: 종료")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        result = hands.process(rgb)

        label = "None"

        # =========================
        # 시작 전
        # =========================
        if not game_started:
            cv2.putText(frame, "PRESS SPACE TO START",
                        (50, 200),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1.2, (0, 255, 255), 3)

            cv2.imshow("KSL GAME FINAL", frame)

            key = cv2.waitKey(1)

            if key == 32:  # SPACE
                game_started = True
                start_time = time.time()
                print("🚀 GAME START")

            elif key == ord('q') or key == 27:
                break

            continue

        # =========================
        # 시간 체크
        # =========================
        elapsed = time.time() - start_time

        if elapsed > GAME_TIME:
            game_over = True

        # =========================
        # 종료 화면
        # =========================
        if game_over:
            cv2.putText(frame, "GAME OVER",
                        (150, 200),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        2, (0, 0, 255), 3)

            cv2.putText(frame, f"FINAL SCORE: {score}",
                        (120, 300),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1.5, (0, 255, 0), 3)

            cv2.imshow("KSL GAME FINAL", frame)

            key = cv2.waitKey(1)

            # 👉 종료 확실하게 처리
            if key in [ord('q'), 113, 27]:
                break

            continue

        # =========================
        # 손 인식
        # =========================
        if result.multi_hand_landmarks:
            for handLms in result.multi_hand_landmarks:

                mp_draw.draw_landmarks(frame, handLms, mp_hands.HAND_CONNECTIONS)

                label = detect_sign(handLms.landmark)

                now = time.time()

                # =========================
                # 정답 처리 (안정화)
                # =========================
                if label == target_sign:
                    if now - last_correct_time > COOLDOWN:
                        score += 10
                        last_correct_time = now
                        print("✔ 정답 +10")

                        next_round()

        # =========================
        # 서버 전송
        # =========================
        send_to_server(label, score, target_sign, "RUNNING")

        # =========================
        # UI
        # =========================
        cv2.putText(frame, f"TARGET: {target_sign}",
                    (30, 50),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1, (255, 0, 0), 2)

        cv2.putText(frame, f"DETECTED: {label}",
                    (30, 90),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1, (0, 255, 0), 2)

        cv2.putText(frame, f"SCORE: {score}",
                    (30, 130),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1, (0, 255, 255), 2)

        cv2.putText(frame, f"TIME: {int(GAME_TIME - elapsed)}",
                    (30, 170),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1, (0, 255, 255), 2)

        cv2.imshow("KSL GAME FINAL", frame)

        # =========================
        # 🔥 핵심: 키 입력 안정 처리
        # =========================
        key = cv2.waitKey(1)

        if key in [ord('q'), 113, 27]:  # q or ESC
            break

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    run()
