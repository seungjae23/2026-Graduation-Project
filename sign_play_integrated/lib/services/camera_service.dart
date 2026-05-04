import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  CameraController? get controller => _controller;

  // 카메라 초기화 함수
  Future<void> initialize() async {
    // 1. 사용 가능한 카메라 리스트 가져오기
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // 2. 전면 카메라 선택 (수어는 본인 모습을 비춰야 하므로)
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // 3. 컨트롤러 설정 (해상도는 중간 정도로 설정하여 AI 부하 감소)
    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false, // 게임이므로 오디오는 일단 끕니다
    );

    // 4. 카메라 실제 연결
    await _controller!.initialize();
  }

  // 앱 종료 시 카메라 자원 해제
  void dispose() {
    _controller?.dispose();
  }
}