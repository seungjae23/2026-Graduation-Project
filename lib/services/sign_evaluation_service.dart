part of '../main.dart';

class SignEvaluationService {
  Interpreter? _interpreter;
  Map<String, String>? _labelMap;
  final LandmarkProcessor _processor = LandmarkProcessor();
  // ML Kit PoseDetector 인스턴스화
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());

  // 1. 모델과 라벨 로드
  Future<void> loadModel(String category) async {
    try {
      _interpreter?.close();
      // Interpreter.fromAsset은 'assets/'를 자동으로 붙여주므로 models/ 경로만 사용
      _interpreter = await Interpreter.fromAsset('assets/models/$category.tflite');
      
      final String jsonString = await rootBundle.loadString('assets/models/${category}_labels.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _labelMap = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      
      print('✅ [$category] 모델 로드 완료!');
    } catch (e) {
      print('❌ 모델 로드 실패: $e');
    }
  }

  // 2. [실시간 스트림용] 랜드마크 추출 및 추론
  Future<String?> predictPose(InputImage inputImage) async {
    // 💡 List<Pose>로 결과를 받아 첫 번째 Pose만 사용하도록 수정
    final List<Pose> results = await _poseDetector.processImage(inputImage);
    
    if (results.isEmpty) return null;

    final List<double> landmarks = _processor.extractAndFlatten(results.first);
    
    // 데이터 90프레임이 꽉 차면 추론 결과 반환
    if (_processor.addFrame(landmarks)) {
      return predict(_processor.getSequencedData());
    }
    return null; // 아직 데이터 모으는 중
  }

  // 3. [비디오 파일 분석용] 영상 파일 분석 (추후 구현 시 사용)
  Future<String?> evaluateVideo(String videoPath) async {
    print("🎥 [AI] 영상 분석 시작: $videoPath");
    _processor.clear();

    List<File> frames = await _extractFrames(videoPath); 

    for (var frameFile in frames) {
      final inputImage = InputImage.fromFile(frameFile);
      final List<Pose> results = await _poseDetector.processImage(inputImage);
      
      if (results.isNotEmpty) {
        List<double> frameData = _processor.extractAndFlatten(results.first);
        _processor.addFrame(frameData);
      }
    }

    final sequenceData = _processor.getSequencedData();
    if (sequenceData.length >= _processor.sequenceLength) {
      return predict(sequenceData);
    }
    return "프레임 부족"; 
  }

  // 추론 로직
  String? predict(List<List<double>> sequenceData) {
    if (_interpreter == null || _labelMap == null) return null;

    var input = [sequenceData];
    int numClasses = _labelMap!.length;
    var output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);

    _interpreter!.run(input, output);

    List<double> resultScores = (output[0] as List).cast<double>();
    int maxIndex = resultScores.indexOf(resultScores.reduce((a, b) => a > b ? a : b));

    return _labelMap![maxIndex.toString()];
  }

  // ffmpeg 프레임 추출 (더미 구현)
  Future<List<File>> _extractFrames(String videoPath) async {
    return [];
  }

  // 자원 해제
  void dispose() {
    _interpreter?.close();
    _poseDetector.close();
  }
}