# Sign Play — 통합 브랜치

실시간 수어 학습 보조 게임 프로젝트 통합본 (2026-05-04)

---

## 📁 폴더 구조

```
sign_play_integrated/
├── android/                  ← Flutter 안드로이드 빌드 설정 (조수혁 android0504)
├── lib/
│   ├── main.dart             ← 앱 진입점 + 공통 PrimaryButton 위젯
│   ├── screens/
│   │   ├── home_screen.dart        ← 홈 화면
│   │   ├── create_room_screen.dart ← 방 만들기 화면
│   │   ├── waiting_room_screen.dart← 대기방 화면 (방 코드 공유)
│   │   └── turn_intro_screen.dart  ← 턴 시작 화면
│   └── services/
│       ├── camera_service.dart     ← 카메라 초기화/해제 서비스
│       └── camera_test_screen.dart ← 카메라 테스트 화면
├── backend/
│   ├── main.py               ← FastAPI 서버 (GRU 모델 추론 API)
│   ├── model_v2.py           ← KeypointGRUModelV2 모델 정의
│   └── models/
│       ├── 가족_model.pth
│       ├── 가족_label_map.pkl
│       ├── 시간_model.pth
│       └── 시간_label_map.pkl
├── data_tools/
│   ├── collect_data.py       ← 손 랜드마크 데이터 수집 (오지성)
│   ├── train_model.py        ← RandomForest 모델 학습 (오지성, 백업용)
│   ├── hand_data.csv         ← 수집된 손 좌표 데이터
│   ├── hand_model.pkl        ← 학습된 RF 모델 (백업용)
│   ├── extract.py            ← 영상 → .npy 좌표 추출 (백승재)
│   └── confirm.py            ← 추출된 .npy 데이터 확인 (백승재)
└── pubspec.yaml
```

---

## 👥 팀원별 기여 파일

| 팀원 | 파일 |
|------|------|
| 조수혁 | `android/`, `lib/` 전체 (Flutter UI) |
| 김효원 | `backend/main.py`, `backend/model_v2.py`, `backend/models/` |
| 오지성 | `data_tools/collect_data.py`, `data_tools/train_model.py`, `data_tools/hand_data.csv`, `data_tools/hand_model.pkl` |
| 백승재 | `data_tools/extract.py`, `data_tools/confirm.py` |

---

## 🚀 실행 방법

### Flutter 앱
```bash
flutter pub get
flutter run
```

### 백엔드 서버
```bash
cd backend
pip install fastapi uvicorn mediapipe torch pillow
uvicorn main:app --host 0.0.0.0 --port 8000
```

### 데이터 수집 (필요 시)
```bash
cd data_tools
python collect_data.py
```

### 영상 전처리 (필요 시)
```bash
cd data_tools
# abs.mp4를 바탕화면에 올린 후 실행
python extract.py
```

---

## ⚠️ 주의사항

- `backend/main.py`는 FastAPI 서버로, Flutter 앱과 별도로 실행해야 합니다.
- `data_tools/collect_data.py`의 폰트 경로(`C:/Windows/Fonts/malgun.ttf`)는 Windows 전용입니다.
- `data_tools/confirm.py`의 경로(`C:/Users/사용자이름/Desktop/...`)는 실행 전 본인 경로로 수정 필요합니다.
