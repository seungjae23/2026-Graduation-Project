part of sign_play;

const String kslModelAssetBasePath = 'assets/ksl_tflite';

const List<String> kslModelCategories = [
  '감정',
  '감정2',
  '감정3',
  '건강',
  '관계',
  '날씨',
  '동물',
  '동사10',
  '동사11',
  '동사12',
  '동사13',
  '동사2',
  '동사3',
  '동사4',
  '동사5',
  '동사6',
  '동사7',
  '동사8',
  '동사9',
  '동작',
  '사람',
  '상태',
  '색깔',
  '스포츠',
  '신체',
  '음식',
  '음식2',
  '의복',
  '일상',
  '자연',
  '장소',
  '직업',
  '학교',
  '형용사',
  '형용사2',
  '형용사3',
];

class KslPrediction {
  final String label;
  final double confidence;
  final String category;

  const KslPrediction({
    required this.label,
    required this.confidence,
    required this.category,
  });
}

class KslLandmarkSequenceBuffer {
  final int sequenceLength;
  final int featureCount;
  final List<List<double>> _frames = [];

  KslLandmarkSequenceBuffer({
    this.sequenceLength = 30,
    this.featureCount = 152,
  });

  bool get isReady => _frames.length == sequenceLength;

  List<List<double>> get frames {
    return _frames.map((frame) => List<double>.of(frame)).toList();
  }

  bool addFrame(List<double> landmarks) {
    if (landmarks.length != featureCount) {
      return false;
    }

    _frames.add(List<double>.of(landmarks));

    if (_frames.length > sequenceLength) {
      _frames.removeAt(0);
    }

    return isReady;
  }

  void clear() {
    _frames.clear();
  }
}

class SignEvaluationService {
  Interpreter? _interpreter;
  String? _loadedCategory;
  Map<int, String> _labels = const {};
  Map<String, String>? _wordCategoryIndex;

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _loadedCategory = null;
    _labels = const {};
  }

  Future<bool> canEvaluateWord(String word) async {
    final category = await categoryForWord(word);
    return category != null;
  }

  Future<String?> categoryForWord(String word) async {
    final index = await _loadWordCategoryIndex();
    return index[normalizeKslText(word)];
  }

  Future<KslPrediction?> evaluate({
    required String targetWord,
    required List<List<double>> landmarks,
  }) async {
    final category = await categoryForWord(targetWord);

    if (category == null) {
      return null;
    }

    await _loadCategory(category);

    final interpreter = _interpreter;
    if (interpreter == null) {
      return null;
    }

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;
    final sequenceLength = inputShape.length >= 3 ? inputShape[1] : 30;
    final featureCount = inputShape.length >= 3 ? inputShape[2] : 152;

    if (landmarks.length != sequenceLength ||
        landmarks.any((frame) => frame.length != featureCount)) {
      return null;
    }

    final outputCount = outputShape.isEmpty ? _labels.length : outputShape.last;
    final output = List.filled(outputCount, 0.0).reshape([1, outputCount]);

    interpreter.run([landmarks], output);

    final scores = (output.first as List).cast<double>();
    var bestIndex = 0;
    var bestScore = scores.isEmpty ? 0.0 : scores.first;

    for (var index = 1; index < scores.length; index += 1) {
      if (scores[index] > bestScore) {
        bestIndex = index;
        bestScore = scores[index];
      }
    }

    final label = _labels[bestIndex];
    if (label == null) {
      return null;
    }

    return KslPrediction(
      label: displayKslText(label),
      confidence: bestScore,
      category: category,
    );
  }

  Future<void> _loadCategory(String category) async {
    if (_loadedCategory == category && _interpreter != null) {
      return;
    }

    _interpreter?.close();
    _interpreter = await Interpreter.fromAsset(_modelAssetPath(category));
    _labels = await _loadLabels(category);
    _loadedCategory = category;
  }

  Future<Map<String, String>> _loadWordCategoryIndex() async {
    final cached = _wordCategoryIndex;
    if (cached != null) {
      return cached;
    }

    final index = <String, String>{};

    for (final category in kslModelCategories) {
      final labels = await _loadLabels(category);

      for (final label in labels.values) {
        index.putIfAbsent(normalizeKslText(label), () => category);
      }
    }

    _wordCategoryIndex = index;
    return index;
  }

  Future<Map<int, String>> _loadLabels(String category) async {
    final jsonString = await rootBundle.loadString(_labelsAssetPath(category));
    final rawLabels = json.decode(jsonString) as Map<String, dynamic>;

    return rawLabels.map((key, value) {
      return MapEntry(int.parse(key), value as String);
    });
  }

  String _modelAssetPath(String category) {
    return '$kslModelAssetBasePath/$category.tflite';
  }

  String _labelsAssetPath(String category) {
    return '$kslModelAssetBasePath/${category}_labels.json';
  }
}
