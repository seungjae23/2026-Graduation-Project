# Sign Play — 통합 프로젝트 (v3)

실시간 수어 학습 보조 게임 프로젝트 통합본
(프론트엔드 2026-05-18 / 오지성 백엔드 2026-05-10 업데이트)

---

## 📁 폴더 구조

```
sign_play_v3/
├── sign_play/              ← Flutter 앱 (조수혁, 최신본)
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── main.dart       ← 진입점 (Firebase 초기화)
│   │   ├── firebase_options.dart
│   │   ├── screens/        ← 화면 10개
│   │   ├── services/       ← WebRTC, 시그널링
│   │   ├── widgets/        ← 공통 위젯
│   │   └── utils/
│   └── pubspec.yaml
│
├── backend/                ← FastAPI GRU 추론 서버 (김효원)
│   ├── main.py
│   ├── model_v2.py         ← GRU 모델 정의
│   └── models/             ← 가족/시간 .pth, .pkl
│
└── data_tools/             ← 데이터 수집/학습 도구
    │
    ├─ 📦 기존 (지문자 ㄱㄴㄷㄹ)
    ├── collect_data.py
    ├── hand_data.csv
    ├── hand_model.pkl      ← RandomForest 모델
    ├── train_model.py
    │
    ├─ 🆕 KSL 한국 수어 자음 (ㄴㄷㅁㅂㅎ)
    ├── ksl_dataset.csv
    ├── ksl_model.pkl       ← MLPClassifier 모델
    ├── label_encoder.pkl
    ├── train_ksl_model.py
    │
    ├─ 🆕 WebSocket 게임 서버
    ├── server.py
    │
    ├─ 🆕 한국어 정답 유사도 판정 ⭐
    ├── similarity.py       ← SBERT 기반 유사도 (70%↑ 정답)
    │
    ├─ 🆕 완성된 게임 로직 (참고용)
    ├── hand_game_final.py
    │
    └─ 📦 영상 전처리 (백승재)
        ├── extract.py
        └── confirm.py
```

---

## 🆕 v3에서 새로 추가된 것들 (오지성 브랜치)

| 파일 | 설명 | 게임 활용도 |
|------|------|------------|
| `ksl_dataset.csv` | 한국 수어 자음 5개 | ⭐⭐ |
| `ksl_model.pkl` | MLP 분류기 (RF보다 정확도 ↑) | ⭐⭐⭐ |
| `train_ksl_model.py` | MLP 학습 코드 | ⭐⭐⭐ |
| `server.py` | WebSocket 게임 서버 | ⭐⭐⭐ |
| **`similarity.py`** | **한국어 SBERT 정답 유사도** | ⭐⭐⭐⭐⭐ |
| `hand_game_final.py` | 점수+콤보+타이머+이펙트 | ⭐⭐⭐⭐ |

### 💎 `similarity.py`가 특별한 이유

```python
# "학교 가기 싫다" 문제 → "오늘 학교 가기 싫어요" 답해도 정답!
# 70%↑ → ✅ 정답 (+10점)
# 50~70% → ⚠️ 비슷함 (+5점)
# 50%↓ → ❌ 오답
```

게임에서 **"비슷한 의미의 답"도 인정**하려면 이 파일이 핵심이에요!

---

## 🚀 실행 방법

### 1️⃣ Flutter 앱

```powershell
cd sign_play
flutter pub get
flutter run
```

> ⚠️ **`google-services.json` 필요!** 백승재 팀장에게 요청

### 2️⃣ 백엔드 서버 (김효원)

```powershell
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000
```

### 3️⃣ 게임 서버 (오지성)

```powershell
cd data_tools
uvicorn server:app --host 0.0.0.0 --port 8001
```

### 4️⃣ 한국 수어 모델 학습

```powershell
cd data_tools
python train_ksl_model.py
```

### 5️⃣ 유사도 테스트

```powershell
pip install sentence-transformers
cd data_tools
python similarity.py
```

---

## ⚠️ `google-services.json`을 찾을 수 없는 이유

이 파일은 **백승재 팀장 컴퓨터에만 있어요!** Firebase 보안 정책상 GitHub에 절대 안 올려요 (`.gitignore`에 자동 추가됨).

**해결 방법 — 백승재에게 요청:**

카톡/슬랙으로:
> "google-services.json 파일 필요해요. sign_play/android/app/ 경로에 넣어야 하는데, Firebase에서 받아서 보내주실 수 있나요?"

받은 파일을 `sign_play/android/app/google-services.json` 위치에 저장하면 끝!

**또는 직접 받기:**
1. 백승재에게 Firebase 프로젝트 `sign-play`에 본인 Google 계정 추가 요청
2. https://console.firebase.google.com 접속
3. `sign-play` 프로젝트 → 프로젝트 설정 → 일반 → Android 앱 → `google-services.json` 다운로드

---

## 📦 추가 Python 패키지

기존에 설치한 것들 외에:

```powershell
pip install sentence-transformers
```

> ⚠️ 1GB 이상 모델 다운로드 (첫 실행 시)

---

## 🎯 전체 게임 흐름

```
[Flutter 앱: 1P, 2P]
    ↓ Firebase Firestore (방 코드)
    ↓ WebRTC (실시간 영상)
[1P 수어 표현]
    ↓ 영상 전송
[2P가 영상 보고 정답 입력]
    ↓
[similarity.py] ← 한국어 SBERT 판정
    ↓ 70%↑ 정답 / 50%↑ 비슷함
[점수 계산 + 화면 출력]
```

---

## 👥 팀원별 기여

| 팀원 | 담당 |
|------|------|
| 조수혁 | Flutter UI (10개 화면) |
| 백승재 | Firebase/WebRTC 구조, 영상 전처리 |
| 김효원 | GRU 모델 + 백엔드 |
| 오지성 | 데이터 수집, KSL 모델, 게임 서버, 유사도 |
| 백세희 | 통합 작업 진행 중 |
