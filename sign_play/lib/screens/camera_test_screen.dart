part of sign_play;

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  int statusIndex = 0;

  final List<_CameraStatus> statuses = const [
    _CameraStatus(
      title: '카메라 권한 대기',
      description: '테스트를 시작하려면 카메라 권한을 허용해주세요.',
      icon: Icons.lock_outline,
      color: Color(0xFFE09A2B),
    ),
    _CameraStatus(
      title: '손 인식 중',
      description: '손이 화면 중앙에 오도록 위치를 맞춰주세요.',
      icon: Icons.back_hand,
      color: Color(0xFF6C63FF),
    ),
    _CameraStatus(
      title: '인식 준비 완료',
      description: '손 위치와 화면 밝기가 안정적입니다.',
      icon: Icons.check_circle,
      color: Color(0xFF1CA56F),
    ),
    _CameraStatus(
      title: '조명이 어두워요',
      description: '밝은 곳으로 이동하거나 손을 더 잘 보이게 해주세요.',
      icon: Icons.light_mode,
      color: Color(0xFFE25B5B),
    ),
  ];

  _CameraStatus get currentStatus => statuses[statusIndex];

  void _nextStatus() {
    setState(() {
      statusIndex = (statusIndex + 1) % statuses.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '카메라 테스트',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E3A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '수어 인식 준비를\n확인해볼까요?',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MediaPipe 연결 전까지는 상태를 직접 바꿔보며\n카메라 테스트 UI를 확인할 수 있어요.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF77778A),
                  ),
                ),
                const SizedBox(height: 28),
                _CameraPreviewPanel(
                  height: 320,
                  overlay: Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: currentStatus.color.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            currentStatus.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              currentStatus.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: currentStatus.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          currentStatus.icon,
                          color: currentStatus.color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentStatus.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E3A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentStatus.description,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Color(0xFF77778A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '촬영 체크리스트',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 14),
                      _GuideText(text: '손과 얼굴이 화면 안에 들어오게 맞춰주세요.'),
                      SizedBox(height: 8),
                      _GuideText(text: '역광이 심하지 않은 밝은 장소에서 테스트해주세요.'),
                      SizedBox(height: 8),
                      _GuideText(text: '손을 너무 빠르게 움직이지 말고 천천히 표현해주세요.'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _PrimaryButton(
                  text: '테스트 상태 변경',
                  icon: Icons.sync,
                  onTap: _nextStatus,
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraStatus {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _CameraStatus({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
