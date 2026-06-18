part of '../main.dart';

class LandmarkProcessor {
  final int sequenceLength = 90; 
  final int featureDim = 152;
  
  final Queue<List<double>> _buffer = Queue();

  List<double> extractAndFlatten(Pose results) {
    List<double> frameData = [];
    final landmarks = results.landmarks;

    for (int i = 0; i < 33; i++) {
      if (landmarks.containsKey(PoseLandmarkType.values[i])) {
        final landmark = landmarks[PoseLandmarkType.values[i]]!;
        frameData.addAll([landmark.x, landmark.y, landmark.z]);
      } else {
        frameData.addAll([0.0, 0.0, 0.0]);
      }
    }

    while (frameData.length < featureDim) {
      frameData.add(0.0);
    }
    
    return frameData.sublist(0, featureDim);
  }

  bool addFrame(List<double> landmarks) {
    if (landmarks.length != featureDim) {
      print("오류: 입력된 랜드마크 개수(${landmarks.length})가 모델 규격($featureDim)과 맞지 않습니다.");
      return false;
    }

    _buffer.add(landmarks);

    if (_buffer.length > sequenceLength) {
      _buffer.removeFirst();
    }
    
    return _buffer.length == sequenceLength;
  }

  List<List<double>> getSequencedData() {
    return _buffer.toList();
  }

  void clear() {
    _buffer.clear();
  }
}