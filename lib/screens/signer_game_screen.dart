part of '../main.dart';

class SignerGameScreen extends StatefulWidget {
  final String playerName;
  final String guesserName;
  final int attackTurn;
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;
  final String? roomCode;
  final List<String> roundWords;

  const SignerGameScreen({
    super.key,
    required this.playerName,
    required this.guesserName,
    required this.attackTurn,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
    this.roomCode,
    required this.roundWords,
  });

  @override
  State<SignerGameScreen> createState() => _SignerGameScreenState();
}

class _SignerGameScreenState extends State<SignerGameScreen> {
  static const int totalRound = 5;
  static const int roundSeconds = 30;
  int currentRound = 1;
  int remainingSeconds = roundSeconds;
  late String currentWord;
  Timer? roundTimer;
  bool isAdvancingRound = false;

  @override
  void initState() {
    super.initState();
    currentWord = widget.roundWords.isNotEmpty ? widget.roundWords[0] : "준비";
    _startRoundTimer();
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    super.dispose();
  }

  void _startRoundTimer() {
    roundTimer?.cancel();
    roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (remainingSeconds <= 1) {
        setState(() => remainingSeconds = 0);
        timer.cancel();
        return;
      }
      setState(() => remainingSeconds -= 1);
    });
  }

  void _advanceRound({required String message}) {
    if (isAdvancingRound) return;
    isAdvancingRound = true;
    roundTimer?.cancel();

    if (currentRound >= totalRound) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResultScreen(
        firstPlayerName: widget.firstPlayerName, secondPlayerName: widget.secondPlayerName,
        firstPlayerScore: widget.firstPlayerScore, secondPlayerScore: widget.secondPlayerScore)));
      return;
    }

    setState(() {
      currentRound += 1;
      currentWord = (currentRound - 1 < widget.roundWords.length) ? widget.roundWords[currentRound - 1] : "종료";
      remainingSeconds = roundSeconds;
      isAdvancingRound = false;
    });

    FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).update({'status': 'playing'});
    _startRoundTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF), 
        elevation: 0, 
        centerTitle: true, 
        title: const Text('표현자 화면', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)))
      ),
      // 💡 여기서 StreamBuilder가 돌지만, 내부의 카메라는 영향을 받지 않도록 분리했습니다.
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final roomData = snapshot.data!.data() as Map<String, dynamic>?;
          final status = roomData?['status'] ?? 'playing';

          if (status == 'round_completed' && !isAdvancingRound) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _advanceRound(message: '2P가 정답을 제출했습니다!'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: _StatusBox(title: '라운드', value: '$currentRound / $totalRound', icon: Icons.flag)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatusBox(title: '남은 시간', value: '$remainingSeconds초', icon: Icons.timer)),
                ]),
                const SizedBox(height: 24),
                Text('${widget.playerName}님 차례예요', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: const Color(0xFF6C63FF), borderRadius: BorderRadius.circular(26)),
                  child: Column(children: [
                    const Text('제시어', style: TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(currentWord, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 24),
                
                // 💡 [핵심] StreamBuilder가 리빌드 되어도 카메라는 끄떡없습니다!
                _CameraRecorderView(roomCode: widget.roomCode!, currentWord: currentWord, status: status),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================
// 💡 독립된 카메라 위젯 (이 안에서만 카메라가 켜지고 유지됨)
// ==========================================================
class _CameraRecorderView extends StatefulWidget {
  final String roomCode;
  final String currentWord;
  final String status;
  const _CameraRecorderView({required this.roomCode, required this.currentWord, required this.status});

  @override
  State<_CameraRecorderView> createState() => _CameraRecorderViewState();
}

class _CameraRecorderViewState extends State<_CameraRecorderView> {
  CameraController? _cameraController;
  bool _isRecording = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (_isRecording) {
      setState(() { _isRecording = false; _isSending = true; });
      final videoFile = await _cameraController!.stopVideoRecording();
      
      try {
        await webRTCService.sendVideoFile(videoFile.path);
        await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).update({
          'status': 'waiting_for_answer',
          'correctAnswer': widget.currentWord,
        });
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('전송 실패: $e')));
        setState(() => _isSending = false);
      }
    } else {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: double.infinity, height: 280, color: Colors.black,
            child: Stack(
              alignment: Alignment.center, fit: StackFit.expand,
              children: [
                if (_cameraController != null && _cameraController!.value.isInitialized) 
                  CameraPreview(_cameraController!),
                  
                if (_isRecording) 
                  const Positioned(top: 18, left: 18, child: RecIndicator()),
                  
                if (_isSending || widget.status == 'waiting_for_answer')
                  Container(
                    color: Colors.black.withOpacity(0.7), 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        const CircularProgressIndicator(color: Colors.white), 
                        const SizedBox(height: 16), 
                        Text(_isSending ? "영상을 전송 중입니다..." : "상대방이 고민 중입니다!", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      ]
                    )
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          text: _isRecording ? '녹화 종료 및 전송' : (widget.status == 'waiting_for_answer' ? '2P 정답 대기 중...' : '수어 동작 녹화 시작'),
          icon: _isRecording ? Icons.send : Icons.videocam,
          enabled: !_isSending && widget.status != 'waiting_for_answer',
          onTap: _toggleRecording,
        ),
      ],
    );
  }
}

class RecIndicator extends StatelessWidget {
  const RecIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(14)),
      child: const Row(children: [
        Icon(Icons.videocam, color: Colors.white, size: 18), 
        SizedBox(width: 8), 
        Text('REC 촬영 중', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
      ]),
    );
  }
}