import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

class GameScreen extends StatefulWidget {
  final String roomCode;     
  final String attackerName;
  
  const GameScreen({super.key, required this.roomCode, required this.attackerName});

  @override
  State<GameScreen> createState() => _GameScreenState(); // 💡 정상적으로 _GameScreenState를 가리킵니다.
}

// 💡 수정됨: 오타였던 _ChangeGameScreenState 이름을 _GameScreenState로 정상 교정했습니다.
class _GameScreenState extends State<GameScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  
  List<String> _words = [];
  String _currentWord = "제시어 로딩 중...";
  bool _isRecording = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    await _loadWords();
    await _initCamera();
  }

  Future<void> _loadWords() async {
    try {
      final String fileText = await rootBundle.loadString('assets/words.txt');
      setState(() {
        _words = fileText.split('\n').map((w) => w.trim()).where((w) => w.isNotEmpty).toList();
        if (_words.isNotEmpty) {
          _currentWord = _words[Random().nextInt(_words.length)];
        } else {
          _currentWord = "수박";
        }
      });
    } catch (e) {
      setState(() => _currentWord = "사과 (기본값)");
    }
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  void _toggleRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });

      await _cameraController!.stopVideoRecording();
      await Future.delayed(const Duration(seconds: 3));

      // AI 통과 완료 상황 가정 (O)
      String mockResult = "O"; 

      if (mockResult == "O") {
        // 1P가 데이터 세팅 후 2P의 정답 입력 대기 상태로 전환
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomCode)
            .update({
              'status': 'waiting_for_answer', 
              'correctAnswer': _currentWord,  
              'videoUrl': 'https://mock-firebase-storage/video.mp4', 
            });

        if (mounted) {
          setState(() => _isAnalyzing = false);
          _showLocalResultDialog("O", "성공! 영상을 상대방에게 보냈습니다. 상대방이 정답을 맞힐 때까지 대기합니다.");
        }
      }
    } else {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  void _showLocalResultDialog(String result, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('분석 완료 ($result)', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); // 인트로 화면으로 복귀 후 2P 기다리기
            },
            child: const Text('확인', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E3A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
                child: Center(
                  child: Text('제시어: $_currentWord', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_cameraController != null && _cameraController!.value.isInitialized)
                        CameraPreview(_cameraController!)
                      else
                        const Center(child: CircularProgressIndicator(color: Colors.white)),
                      
                      if (_isAnalyzing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.7),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text("AI가 동작을 분석 중입니다...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop_rounded : Icons.videocam_rounded),
                  label: Text(
                    _isRecording ? '녹화 종료 및 결과 확인' : '수어 녹화 시작',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.redAccent : const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}