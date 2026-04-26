import cv2
import numpy as np
import mediapipe as mp
from PIL import ImageFont, ImageDraw, Image

# MediaPipe Hands 초기화
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)
mp_draw = mp.solutions.drawing_utils

# --- 거리 계산 ---
def get_distance(p1, p2):
    return np.linalg.norm(np.array(p1) - np.array(p2))

# --- 점수 계산 ---
def calculate_score(landmarks):
    tips = [8, 12, 16, 20]
    score = 0

    for tip in tips:
        dist = get_distance(landmarks[tip], landmarks[0])  # wrist 기준
        if dist > 100:
            score += 10

    return score

# --- KSL 문자 인식 ---
def classify_ksl(lm_list):
    wrist = lm_list[0]
    tips = [8, 12, 16, 20]

    fingers = []

    for tip in tips:
        dist = get_distance(lm_list[tip], wrist)

        if dist > 120:   # ⭐ 필요하면 80~150 사이로 조절
            fingers.append(1)
        else:
            fingers.append(0)

    # fingers = [검지, 중지, 약지, 새끼]

    if fingers == [0, 0, 0, 0]:
        return "ㄱ"
    elif fingers == [1, 0, 0, 0]:
        return "ㄴ"
    elif fingers == [1, 1, 0, 0]:
        return "ㄷ"
    else:
        return "Unknown"

# --- 메인 실행 ---
def run():
    cap = cv2.VideoCapture(0)
    print("프로그램 시작. q 누르면 종료")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)
        h, w, _ = frame.shape

        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        result = hands.process(rgb)

        label = "Unknown"
        score = 0

        if result.multi_hand_landmarks:
            for handLms in result.multi_hand_landmarks:
                lm_list = []

                for lm in handLms.landmark:
                    lm_list.append((lm.x * w, lm.y * h))

                # 점수 계산
                score = calculate_score(lm_list)

                # KSL 문자 인식
                label = classify_ksl(lm_list)

                # 랜드마크 그리기
                mp_draw.draw_landmarks(frame, handLms, mp_hands.HAND_CONNECTIONS)

        # --- 한글 출력 (핵심 수정 부분) ---
        pil_img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
        draw = ImageDraw.Draw(pil_img)

        # ⭐ Windows 기본 한글 폰트 사용
        font = ImageFont.truetype("C:/Windows/Fonts/malgun.ttf", 40)

        draw.text((30, 30), f"Detected: {label}", font=font, fill=(0,255,0))
        draw.text((30, 90), f"Score: {score}", font=font, fill=(0,255,255))

        frame = cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)

        cv2.imshow("Hand Score", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    run()