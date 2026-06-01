import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import joblib

# =========================
# 👉 데이터 불러오기 (한글 인코딩 해결)
# =========================
try:
    df = pd.read_csv("hand_data.csv", encoding="cp949")
except:
    df = pd.read_csv("hand_data.csv", encoding="euc-kr")

# =========================
# 👉 데이터 확인
# =========================
print("📊 데이터 미리보기")
print(df.head())

# =========================
# 👉 특징 / 라벨 분리
# =========================
X = df.drop("label", axis=1)
y = df["label"]

# =========================
# 👉 모델 생성 및 학습
# =========================
model = RandomForestClassifier(
    n_estimators=100,
    random_state=42
)

model.fit(X, y)

# =========================
# 👉 모델 저장
# =========================
joblib.dump(model, "hand_model.pkl")

print("\n✅ 학습 완료!")
print("👉 hand_model.pkl 생성됨")