part of '../main.dart';

class _CameraPreviewPanel extends StatefulWidget {
  final double height;
  final Widget? overlay;

  const _CameraPreviewPanel({
    required this.height,
    this.overlay,
  });

  @override
  State<_CameraPreviewPanel> createState() => _CameraPreviewPanelState();
}

class _CameraPreviewPanelState extends State<_CameraPreviewPanel>
    with WidgetsBindingObserver {
  CameraController? cameraController;
  Future<void>? cameraFuture;
  String? cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cameraFuture = _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cameraController?.dispose();

      if (mounted) {
        setState(() {
          cameraController = null;
        });
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      setState(() {
        cameraFuture = _initializeCamera();
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          cameraError = '사용 가능한 카메라가 없습니다.';
        });
        return;
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high, // medium -> high 로 변경
        enableAudio: true,     // false -> true 로 변경
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        cameraController = controller;
        cameraError = null;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraError = _messageForCameraError(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraError = '카메라를 시작할 수 없습니다.';
      });
    }
  }

  String _messageForCameraError(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
      case 'cameraPermission':
        return '카메라 권한을 허용해주세요.';
      case 'CameraAccessDeniedWithoutPrompt':
        return '설정에서 카메라 권한을 켜주세요.';
      default:
        return '카메라를 시작할 수 없습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        height: widget.height,
        color: const Color(0xFF2E2E3A),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<void>(
              future: cameraFuture,
              builder: (context, snapshot) {
                final controller = cameraController;

                if (cameraError != null) {
                  return _CameraPreviewMessage(
                    icon: Icons.no_photography,
                    title: '카메라 연결 실패',
                    description: cameraError!,
                  );
                }

                if (controller == null || !controller.value.isInitialized) {
                  return const _CameraPreviewMessage(
                    icon: Icons.camera_alt,
                    title: '카메라 준비 중',
                    description: '카메라 권한 요청과 초기화를 진행하고 있어요.',
                  );
                }

                return Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  ),
                );
              },
            ),
            if (widget.overlay != null) widget.overlay!,
          ],
        ),
      ),
    );
  }
}

class _CameraPreviewMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CameraPreviewMessage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(icon, color: Colors.white, size: 42),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
