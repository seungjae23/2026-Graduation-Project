import cv2
import websocket
import numpy as np
import json
from PIL import ImageFont, ImageDraw, Image 

# 서버 주소
uri = "ws://127.0.0.1:8000/ws/sign-language"

print("🌐 서버에 연결을 시도합니다...")
try:
    ws = websocket.create_connection(uri)
    print("✅ 서버에 성공적으로 연결되었습니다.")
except Exception as e:
    print(f"❌ 서버 연결 실패: {e}")
    exit()

# 🚀 딜레이 해결: cv2.CAP_DSHOW 속성 추가
print("📷 카메라를 불러오는 중입니다... (보통 1~2초 내에 켜집니다)")
cap = cv2.VideoCapture(0)

cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

try:
    font = ImageFont.truetype("malgun.ttf", 40)
except IOError:
    print("⚠️ 맑은 고딕 폰트를 찾을 수 없습니다. 기본 폰트로 대체합니다.")
    font = ImageFont.load_default()

print("🎮 시작하려면 카메라 창을 클릭하고 'q'를 누르면 종료됩니다.")

try:
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)

        _, buffer = cv2.imencode('.jpg', frame)
        ws.send_binary(buffer.tobytes())

        response = ws.recv()
        result = json.loads(response)
        label = result.get("label", "Unknown")

        img_pil = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
        draw = ImageDraw.Draw(img_pil)
        
        text = f"인식 결과: {label}"
        draw.text((20, 30), text, font=font, fill=(0, 255, 0))

        frame = cv2.cvtColor(np.array(img_pil), cv2.COLOR_RGB2BGR)

        cv2.imshow('KSL Recognition Test', frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
finally:
    cap.release()
    cv2.destroyAllWindows()
    ws.close()
    print("👋 프로그램이 종료되었습니다.")
