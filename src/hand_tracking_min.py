import cv2
import mediapipe as mp

# ---------------------------
# mediapipe 세팅
# ---------------------------
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,       # 영상이면 False
    max_num_hands=2,               # 최대 2손
    min_detection_confidence=0.7,  # 인식 신뢰도
    min_tracking_confidence=0.7    # 추적 신뢰도
)
mp_draw = mp.solutions.drawing_utils

# ---------------------------
# 카메라 열기
# ---------------------------
cap = cv2.VideoCapture(0)  # 기본 카메라

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # BGR -> RGB 변환
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # mediapipe 손 인식
    results = hands.process(rgb_frame)

    # 인식된 손 그리기
    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

    # 화면 출력
    cv2.imshow("Hand Tracking", frame)

    # q 누르면 종료
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()