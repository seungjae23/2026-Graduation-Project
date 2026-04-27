import cv2
import mediapipe as mp
import numpy as np
import os

# 1. 바탕화면 경로 자동 설정 (윈도우/맥 공통)
desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
video_path = os.path.join(desktop_path, "abs.mp4") # 원본 동영상
save_path = os.path.join(desktop_path, "abs_coordinates.npy") # 저장될 좌표 파일

# 2. MediaPipe 초기화
mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(static_image_mode=False, min_detection_confidence=0.5)

def extract_landmarks(video_path):
    cap = cv2.VideoCapture(video_path)
    all_landmarks = [] # 전체 프레임의 좌표를 담을 큰 바구니

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret: 
            break # 영상이 끝나면 반복문 탈출

        # 성능을 위해 BGR을 RGB로 변환
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = holistic.process(image)

        # 1프레임당 추출할 좌표들을 담을 빈 리스트
        frame_data = []

        # [주의] 손이나 몸이 화면에 안 잡힐 수도 있으므로 예외 처리가 필수입니다.

        # 1. 왼손 좌표 추출 (21개 랜드마크 * x, y, z = 총 63개 숫자)
        if results.left_hand_landmarks:
            for res in results.left_hand_landmarks.landmark:
                frame_data.extend([res.x, res.y, res.z])
        else:
            frame_data.extend([0.0] * 63) # 화면에 왼손이 안 보이면 0으로 채움

        # 2. 오른손 좌표 추출 (21개 랜드마크 * x, y, z = 총 63개 숫자)
        if results.right_hand_landmarks:
            for res in results.right_hand_landmarks.landmark:
                frame_data.extend([res.x, res.y, res.z])
        else:
            frame_data.extend([0.0] * 63)

        # 3. 포즈(몸통/팔) 좌표 추출 (필요한 경우)
        # 만약 기존 모델이 '152개' 좌표를 쓴다면, 이 부분에서 모델이 원하는 부위만 골라내야 합니다.
        if results.pose_landmarks:
            for res in results.pose_landmarks.landmark:
                frame_data.extend([res.x, res.y, res.z, res.visibility])
        else:
            frame_data.extend([0.0] * 132) # 포즈 랜드마크 33개 * 4 = 132

        # 추출된 1장의 사진 분량 좌표를 큰 바구니에 담기
        all_landmarks.append(frame_data)

    cap.release()
    return np.array(all_landmarks) # 파이썬 리스트를 Numpy 배열로 변환

# ==========================================
# 실행 부분
# ==========================================
if __name__ == "__main__":
    print(f"🎬 '{video_path}' 영상에서 좌표를 뽑아냅니다...")
    
    # 함수 실행
    extracted_data = extract_landmarks(video_path)

    if len(extracted_data) > 0:
        # 추출된 데이터를 .npy 파일로 바탕화면에 저장
        np.save(save_path, extracted_data)
        print(f"✅ 완료! 총 {len(extracted_data)} 프레임의 좌표가 저장되었습니다.")
        print(f"💾 저장 위치: {save_path}")
        print("💡 이제 수백 MB짜리 원본 동영상은 지우셔도 됩니다!")
    else:
        print("❌ 동영상을 찾을 수 없거나 영상을 읽지 못했습니다. 파일명과 경로를 확인해 주세요.")
