part of '../main.dart';

class CameraRecorderWidget extends StatefulWidget {
  final String roomCode;
  final String currentWord;
  final String status;

  const CameraRecorderWidget({
    super.key,
    required this.roomCode,
    required this.currentWord,
    required this.status,
  });

  @override
  State<CameraRecorderWidget> createState() => _CameraRecorderWidgetState();
}

class _CameraRecorderWidgetState extends State<CameraRecorderWidget> {
  CameraController? _cameraController;
  final SignEvaluationService _aiService = SignEvaluationService();
  
  bool _isProcessing = false;
  bool _isAnalyzingFrame = false;
  String? _aiResultText; // 💡 화면에 띄울 AI 예측 결과를 저장할 변수 추가!

  @override
  void initState() {
    super.initState();
    _initCamera();
    _aiService.loadModel(_getCategoryForWord(widget.currentWord));
  }

  @override
  void didUpdateWidget(covariant CameraRecorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWord != widget.currentWord) {
      _aiService.loadModel(_getCategoryForWord(widget.currentWord));
      // 단어가 바뀌면 이전 결과 지우기
      setState(() {
        _aiResultText = null;
      });
    }
  }

  String _getCategoryForWord(String word) {
    return WordService.getCategoryForWord(word);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    
    _cameraController = CameraController(
      frontCamera, 
      ResolutionPreset.low, 
      enableAudio: false
    );
    
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _startLiveStream() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    setState(() {
      _isProcessing = true;
      _aiResultText = null; // 💡 새로운 녹화 시작 시 이전 결과 화면에서 지우기
    });
    
    _aiService._processor.clear();

    await _cameraController!.startImageStream((CameraImage image) async {
      if (!_isProcessing || _isAnalyzingFrame) return;

      _isAnalyzingFrame = true; 

      try {
        final inputImage = _inputImageFromCameraImage(image);
        final result = await _aiService.predictPose(inputImage);
        
        if (result != null) {
          _stopLiveStream(result);
        }
      } catch (e) {
        print("❌ 분석 에러: $e");
      } finally {
        _isAnalyzingFrame = false; 
      }
    });
  }

  void _stopLiveStream([String? result]) {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
    
    setState(() {
      _isProcessing = false;
      _aiResultText = result; // 💡 화면에 띄우기 위해 변수에 결과 저장!
    });
    
    if (result != null) {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .update({
        'status': 'waiting_for_answer',
        'detectedWord': result,
      });
    }
  }

  InputImage _inputImageFromCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    
    return InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
    _cameraController?.dispose();
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _cameraController != null && _cameraController!.value.isInitialized
              ? SizedBox(height: 300, child: CameraPreview(_cameraController!))
              : const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
        ),
        const SizedBox(height: 16),
        _ActionBtn(
          text: _isProcessing ? '분석 중 (중단하려면 누르세요)' : '녹화 시작',
          icon: Icons.videocam,
          enabled: widget.status != 'waiting_for_answer',
          onTap: _isProcessing ? () => _stopLiveStream(null) : _startLiveStream,
        ),
        
        // 💡 AI가 결과를 내놓았을 때만 짜잔! 하고 나타나는 결과 박스
        if (_aiResultText != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade300, width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  '🤖 AI 예측 결과',
                  style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _aiResultText!,
                  style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }
}

// 이 파일 내부에서만 사용하는 버튼 클래스
class _ActionBtn extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.text,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF6C63FF) : Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}