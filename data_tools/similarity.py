from sentence_transformers import SentenceTransformer, util
import random

# 1. 모델 로드
model = SentenceTransformer('snunlp/KR-SBERT-V40K-klueNLI-augSTS')

# 2. 문제 데이터
problems = [
    {
        "question": "학교 가기 싫다",
        "answers": ["학교 가기 싫다", "오늘 학교 가기 싫어요", "등교하기 싫다"]
    },
    {
        "question": "배고프다",
        "answers": ["배고프다", "배가 고파요", "지금 배고픔"]
    },
    {
        "question": "집에 가고 싶다",
        "answers": ["집에 가고 싶다", "집 가고 싶어요", "지금 집에 가고 싶음"]
    }
]

# 🔥 3. 정답 벡터 미리 생성 (핵심)
for problem in problems:
    problem["embeddings"] = model.encode(problem["answers"], convert_to_tensor=True)

score = 0

# 4. 게임 반복
for i in range(3):  # 문제 3개
    problem = random.choice(problems)

    print("\n🎮 문제:", problem["question"])
    user_input = input("👉 정답을 입력하세요: ")

    # 🔥 사용자 입력만 벡터화
    user_embedding = model.encode(user_input, convert_to_tensor=True)

    # 🔥 유사도 계산 (한 번에)
    scores = util.cos_sim(user_embedding, problem["embeddings"])

    best_score = scores.max().item()

    print(f"유사도 점수: {best_score:.4f}")

    # 5. 판정
    if best_score > 0.7:
        print("✅ 정답!")
        score += 10
    elif best_score > 0.5:
        print("⚠️ 비슷함!")
        score += 5
    else:
        print("❌ 오답!")

print(f"\n🏁 최종 점수: {score}")



'''
from sentence_transformers import SentenceTransformer, util
import random

# 모델 로드
model = SentenceTransformer('snunlp/KR-SBERT-V40K-klueNLI-augSTS')

# 문제 데이터 (나중에 DB로 바뀜)
problems = [
    {
        "question": "학교 가기 싫다",
        "answers": ["학교 가기 싫다", "오늘 학교 가기 싫어요", "등교하기 싫다"]
    },
    {
        "question": "배고프다",
        "answers": ["배고프다", "배가 고파요", "지금 배고픔"]
    },
    {
        "question": "집에 가고 싶다",
        "answers": ["집에 가고 싶다", "집 가고 싶어요", "지금 집에 가고 싶음"]
    }
]

score = 0

# 랜덤 문제 선택
problem = random.choice(problems)

print("🎮 문제:", problem["question"])

# 사용자 입력
user_input = input("👉 정답을 입력하세요: ")

best_score = 0

# 모든 정답과 비교
for ans in problem["answers"]:
    emb1 = model.encode(ans, convert_to_tensor=True)
    emb2 = model.encode(user_input, convert_to_tensor=True)

    score_tmp = util.cos_sim(emb1, emb2).item()

    if score_tmp > best_score:
        best_score = score_tmp

print(f"\n유사도 점수: {best_score:.4f}")

# 판정
if best_score > 0.7:
    print("✅ 정답!")
    score += 10
elif best_score > 0.5:
    print("⚠️ 비슷함!")
    score += 5
else:
    print("❌ 오답!")

print(f"현재 점수: {score}")

for i in range(3):  # 3문제 진행
    problem = random.choice(problems)

    print("\n🎮 문제:", problem["question"])
    user_input = input("👉 정답을 입력하세요: ")

    best_score = 0

    for ans in problem["answers"]:
        emb1 = model.encode(ans, convert_to_tensor=True)
        emb2 = model.encode(user_input, convert_to_tensor=True)

        score_tmp = util.cos_sim(emb1, emb2).item()

        if score_tmp > best_score:
            best_score = score_tmp

    print(f"유사도 점수: {best_score:.4f}")

    if best_score > 0.7:
        print("✅ 정답!")
        score += 10
    elif best_score > 0.5:
        print("⚠️ 비슷함!")
        score += 5
    else:
        print("❌ 오답!")

print(f"\n🏁 최종 점수: {score}")
'''