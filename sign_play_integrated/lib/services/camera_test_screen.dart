import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_service.dart';

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  final CameraService _cameraService = CameraService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  // 카메라를 켜는 준비 과정
  Future<void> _prepareCamera() async {
    await _cameraService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraService.dispose(); // 화면을 나갈 때 카메라를 끕니다
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카메라 테스트'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: _isInitialized
            ? Container(
                margin: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1, // 정사각형 형태로 보여줍니다
                    child: CameraPreview(_cameraService.controller!),
                  ),
                ),
              )
            : const CircularProgressIndicator(), // 로딩 중일 때 도는 아이콘
      ),
    );
  }
}