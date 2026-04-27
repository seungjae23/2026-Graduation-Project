import numpy as np

# 바탕화면의 npy 파일 읽기
data = np.load('C:/Users/사용자이름/Desktop/abs_coordinates.npy')

# 데이터 생김새 확인하기
print("데이터 형태:", data.shape) # 예: (90, 258) -> 90장 사진에서 258개 숫자씩 뽑힘
print("첫 번째 사진의 좌표들:", data[0])
