part of '../main.dart';

class LandmarkProcessor {
  // 모델 학습 시 설정했던 파라미터
  final int sequenceLength = 30; 
  final int featureDim = 152;
  
  // FIFO (First-In-First-Out) 구조로 데이터를 관리할 큐
  final Queue<List<double>> _buffer = Queue();

  // ====================================================================
  // 💡 [NEW] 완전판 추가 기능: MediaPipe 결과를 152개 좌표로 변환합니다.
  // ====================================================================
  List<double> extractAndFlatten(dynamic results) {
    List<double> frameData = [];

    // 1. 왼손 좌표 추출 (21개 * x,y,z = 63개)
    if (results.leftHandLandmarks != null) {
      for (var landmark in results.leftHandLandmarks.landmark) {
        frameData.addAll([landmark.x, landmark.y, landmark.z]);
      }
    } else {
      frameData.addAll(List.filled(63, 0.0)); // 안 보이면 0.0
    }

    // 2. 오른손 좌표 추출 (21개 * x,y,z = 63개)
    if (results.rightHandLandmarks != null) {
      for (var landmark in results.rightHandLandmarks.landmark) {
        frameData.addAll([landmark.x, landmark.y, landmark.z]);
      }
    } else {
      frameData.addAll(List.filled(63, 0.0)); // 안 보이면 0.0
    }

    // 3. 포즈(몸통) 좌표 추출 -> (13개 관절 * x,y = 26개)
    // 총합: 왼손(63) + 오른손(63) + 포즈(26) = 정확히 152개 완성!
    if (results.poseLandmarks != null) {
      // 상체 관절 위주로 13개만 뽑아냅니다. (파이썬에서 학습한 부위에 맞춤)
      for (int i = 0; i < 13; i++) { 
        if (i < results.poseLandmarks.landmark.length) {
          var landmark = results.poseLandmarks.landmark[i];
          frameData.addAll([landmark.x, landmark.y]); // z와 visibility는 제외
        } else {
          frameData.addAll([0.0, 0.0]); // 안전 장치
        }
      }
    } else {
      frameData.addAll(List.filled(26, 0.0)); // 안 보이면 0.0으로 26개 채움
    }

    return frameData;
  }

  // ====================================================================
  // 아래는 기존에 있던 컨베이어 벨트(큐) 로직입니다.
  // ====================================================================

  /// 새로운 프레임 데이터(152개)를 큐에 추가합니다.
  /// 30개가 꽉 찼는지(모델 추론 가능 여부)를 bool로 반환합니다.
  bool addFrame(List<double> landmarks) {
    if (landmarks.length != featureDim) {
      print("오류: 입력된 랜드마크 개수(${landmarks.length})가 모델 규격($featureDim)과 맞지 않습니다.");
      return false;
    }

    // 1. 새 프레임 추가
    _buffer.add(landmarks);

    // 2. 30개가 넘어가면 가장 오래된 프레임(첫 번째)을 제거
    if (_buffer.length > sequenceLength) {
      _buffer.removeFirst();
    }
    
    // 3. 30개가 다 모였는지 확인
    return _buffer.length == sequenceLength;
  }

  /// 모델에 넣기 위한 2차원 리스트 형태 [30, 152]로 반환합니다.
  List<List<double>> getSequencedData() {
    return _buffer.toList();
  }

  /// 새로운 단어를 시작할 때 버퍼를 비워줍니다.
  void clear() {
    _buffer.clear();
  }
}