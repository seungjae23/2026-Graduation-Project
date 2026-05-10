import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.neural_network import MLPClassifier
import joblib

# 데이터 로드
df = pd.read_csv("ksl_dataset.csv", encoding="cp949")

# X, y 분리
X = df.iloc[:, 1:].values
y = df.iloc[:, 0].values

# 라벨 인코딩
le = LabelEncoder()
y_encoded = le.fit_transform(y)

# 데이터 분리
X_train, X_test, y_train, y_test = train_test_split(X, y_encoded, test_size=0.2)

# 모델 생성
model = MLPClassifier(hidden_layer_sizes=(128, 64), max_iter=500)

# 학습
model.fit(X_train, y_train)

# 정확도 출력
accuracy = model.score(X_test, y_test)
print(f"모델 정확도: {accuracy * 100:.2f}%")

# 저장
joblib.dump(model, "ksl_model.pkl")
joblib.dump(le, "label_encoder.pkl")

print("모델 저장 완료")