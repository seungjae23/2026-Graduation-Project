# Sign Play

실시간 수어 학습 보조 게임 (2026 졸업프로젝트 2조)

## 폴더 구조

- sign_play/ — Flutter 앱
- backend/ — FastAPI 백엔드 서버
- data_tools/ — 데이터 수집 및 모델 학습 도구

## 실행 방법

### Flutter 앱

cd sign_play
flutter pub get
flutter run

### 백엔드 서버

cd backend
uvicorn main:app --host 0.0.0.0 --port 8000

## 팀원

- 백승재 (팀장)
- 김효원
- 조수혁
- 오지성
- 백세희
