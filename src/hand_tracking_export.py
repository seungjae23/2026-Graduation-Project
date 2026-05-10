import cv2
import mediapipe as mp
import csv
import time
import os

# ---------------------------
# mediapipe 세팅
# ---------------------------
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=2,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7
)
mp_draw = mp.solutions.drawing_utils

# ---------------------------
# CSV 저장 준비
# ---------------------------
output_dir = "hand_data"
os.makedirs(output_dir, exist_ok=True)
timestamp = int(time.time())
csv_file = os.path.join(output_dir, f"hand_landmarks_{timestamp}.csv")

# CSV 헤더 생성
header = ["frame"]
for i in range(21):  # 손 랜드마크 21개
    header += [f"x{i}", f"y{i}", f"z{i}"]

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

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            # 랜드마크 좌표 추가
            for lm in hand_landmarks.landmark:
                row += [lm.x, lm.y, lm.z]
            # 화면에 손 그림 그리기
            mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)
    else:
        # 손이 없으면 21*3 개 만큼 빈 값 추가
        row += [None] * 63

    # CSV 저장
    with open(csv_file, mode="a", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(row)

    frame_count += 1

    # 화면 출력
    cv2.imshow("Hand Tracking Export", frame)

    # q 누르면 종료
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
print(f"Data saved to {csv_file}")