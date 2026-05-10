import cv2
import numpy as np
import mediapipe as mp
from mediapipe.tasks import python

# --- 모델 로드 ---
model_path = r"C:\Users\JiSungOh\Desktop\Graduation Project1\SourceCodes\hand_landmarker.task"
base_options = python.BaseOptions(model_asset_path=model_path)
options = mp.tasks.vision.HandLandmarkerOptions(base_options=base_options, num_hands=1)
detector = mp.tasks.vision.HandLandmarker.create_from_options(options)

# --- 간단 점수 계산용 예시 정답 ---
TARGET_LABEL = "ㄱ"
score = 0

def get_dist(p1, p2):
    return np.sqrt((p1.x - p2.x)**2 + (p1.y - p2.y)**2)

def get_angle(p1, p2, p3):
    v1 = np.array([p1.x - p2.x, p1.y - p2.y])
    v2 = np.array([p3.x - p2.x, p3.y - p2.y])
    n1, n2 = np.linalg.norm(v1), np.linalg.norm(v2)
    if n1 == 0 or n2 == 0: return 0
    return np.degrees(np.arccos(np.clip(np.dot(v1, v2)/(n1*n2), -1.0, 1.0)))

# --- 웹캠 루프 ---
cap = cv2.VideoCapture(0)
while cap.isOpened():
    ret, frame = cap.read()
    if not ret: break

    frame = cv2.flip(frame, 1)
    h, w, _ = frame.shape
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    res = detector.detect(mp_image)
    label = "Unknown"

    if res.hand_landmarks:
        for landmarks in res.hand_landmarks:
            angles = [get_angle(landmarks[i], landmarks[i-2], landmarks[i-3]) for i in [8,12,16,20]]
            ext = [a>135 for a in angles]
            # 간단 예시: 한 개만 폈으면 ㄱ
            if sum(ext)==1 and ext[0]: label="ㄱ"
            elif sum(ext)==0: label="ㅁ"

            for lm in landmarks:
                cv2.circle(frame, (int(lm.x*w), int(lm.y*h)), 5, (0,255,0), -1)

    # 점수 계산
    if label == TARGET_LABEL:
        score = 10
    else:
        score = 0

    cv2.putText(frame, f"Detected: {label} | Score: {score}", (20,50),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)
    
    cv2.imshow("Hand Scoring Test", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'): break

cap.release()
cv2.destroyAllWindows()