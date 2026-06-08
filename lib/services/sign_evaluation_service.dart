part of '../main.dart';

class SignEvaluationService {
  Interpreter? _interpreter;
  Map<int, String>? _labelMap;

  // 1. 모델과 라벨맵 로드 (앱 시작 시 호출)
  Future<void> init() async {
    // TFLite 모델 로드
    _interpreter = await Interpreter.fromAsset('models/your_model.tflite');
    
    // 라벨맵 로드 (모델이 0, 1, 2...로 뱉은 숫자를 '가다', '먹다'로 바꿔줄 사전)
    final String jsonString = await rootBundle.loadString('assets/data/label_map.json');
    final Map<String, dynamic> rawMap = json.decode(jsonString);
    _labelMap = rawMap.map((key, value) => MapEntry(value as int, key));
  }

  // 2. 추론 함수 (MediaPipe 좌표가 들어오면 동작)
  Future<String?> evaluate(List<List<double>> landmarks) async {
    if (_interpreter == null) return null;

    // 모델 입력 형식에 맞춰 변환 [1, 30, 152] 텐서 형태
    var input = [landmarks]; 
    var output = List.filled(1 * 13, 0).reshape([1, 13]); // 13은 모델의 클래스 개수(동사13)

    _interpreter!.run(input, output);

    // 가장 확률이 높은 인덱스 찾기
    int predictedIndex = output[0].indexOf(output[0].reduce((curr, next) => curr > next ? curr : next));
    
    return _labelMap?[predictedIndex];
  }
}