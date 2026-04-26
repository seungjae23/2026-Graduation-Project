# <hand_score_game.py>
import cv2
import numpy as np
import mediapipe as mp
from mediapipe.tasks import python
from PIL import ImageFont, ImageDraw, Image
import os

# --- [1. 환경 설정] ---
font_path = "NanumGothicBold.ttf"
model_path = "hand_landmarker.task"

# 모델 다운로드
if not os.path.exists(model_path):
    import urllib.request
    print("모델 파일 다운로드 중...")
    url = "https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task"
    urllib.request.urlretrieve(url, model_path)

# MediaPipe 설정
base_options = python.BaseOptions(model_asset_path=model_path)
options = mp.tasks.vision.HandLandmarkerOptions(base_options=base_options, num_hands=1)
detector = mp.tasks.vision.HandLandmarker.create_from_options(options)

# --- [2. 좌표 기반 KSL 글자 판정 & 점수] ---
def get_dist(p1, p2):
    return np.sqrt((p1.x - p2.x)**2 + (p1.y - p2.y)**2)

def get_angle(p1, p2, p3):
    v1 = np.array([p1.x - p2.x, p1.y - p2.y])
    v2 = np.array([p3.x - p2.x, p3.y - p2.y])
    n1, n2 = np.linalg.norm(v1), np.linalg.norm(v2)
    if n1 == 0 or n2 == 0: return 0
    return np.degrees(np.arccos(np.clip(np.dot(v1, v2) / (n1*n2), -1.0, 1.0)))

def classify_ksl(landmarks):
    """
    좌표 기반 KSL 글자 판정
    점수: 0~100
    """
    h_score = 0
    label = "Unknown"

    # 손가락 펴짐 확인
    angles = [get_angle(landmarks[i], landmarks[i-2], landmarks[i-3]) for i in [8, 12, 16, 20]]
    ext = [a > 135 for a in angles]
    num_ext = sum(ext)

    # 엄지 위치
    thumb_v = (landmarks[4].x - landmarks[2].x, landmarks[4].y - landmarks[2].y)
    idx_v = (landmarks[8].x - landmarks[5].x, landmarks[8].y - landmarks[5].y)

    # 간단 룰로 글자 판정
    if num_ext == 0:
        label = "ㅁ" if landmarks[4].x < landmarks[5].x else "ㅇ"
        h_score = 20
    elif num_ext == 1 and ext[0]:
        label = "ㄱ" if abs(thumb_v[0]) > abs(thumb_v[1]) else "ㄴ"
        h_score = 30
    elif num_ext == 2 and ext[0] and ext[1]:
        label = "ㄷ" if abs(idx_v[0]) > abs(idx_v[1]) else "ㅅ"
        h_score = 50
    elif num_ext == 3 and ext[0] and ext[1] and ext[2]:
        label = "ㄹ" if abs(idx_v[0]) > abs(idx_v[1]) else "ㅂ"
        h_score = 70
    elif all(ext):
        label = "ㅎ"
        h_score = 100
    else:
        label = "???"
        h_score = 10  # 애매한 경우에도 점수

    return label, h_score

# --- [3. 메인 루프] ---
def run_ksl_game():
    cap = cv2.VideoCapture(0)
    print("KSL 점수 게임 시작! 종료는 'q'")

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret: break

        frame = cv2.flip(frame, 1)
        h, w, _ = frame.shape
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
        res = detector.detect(mp_image)

        label = "Unknown"
        score = 0

        if res.hand_landmarks:
            for landmarks in res.hand_landmarks:
                # 좌표 기반 판정
                label, score = classify_ksl(landmarks)

                # 좌표 표시
                for lm in landmarks:
                    cv2.circle(frame, (int(lm.x*w), int(lm.y*h)), 5, (0, 255, 0), -1)

        # 화면에 점수 + 글자 표시
        try:
            pil_img = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            draw = ImageDraw.Draw(pil_img)
            font = ImageFont.truetype(font_path, 40)
            draw.text((30, 30), f"Detected: {label}", font=font, fill=(0, 255, 0))
            draw.text((30, 80), f"Score: {score}", font=font, fill=(0, 255, 0))
            frame = cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)
        except:
            cv2.putText(frame, f"Detected: {label}", (30, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)
            cv2.putText(frame, f"Score: {score}", (30, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)

        cv2.imshow("KSL Game Score", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'): break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    run_ksl_game()