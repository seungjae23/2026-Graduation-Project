part of '../main.dart';

class GuesserGameScreen extends StatefulWidget {
  final String guesserName;
  final String signerName;
  final int attackTurn;
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;
  final String? roomCode;
  final List<String> roundWords;

  const GuesserGameScreen({
    super.key,
    required this.guesserName,
    required this.signerName,
    required this.attackTurn,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
    this.roomCode,
    required this.roundWords,
  });

  @override
  State<GuesserGameScreen> createState() => _GuesserGameScreenState();
}

class _GuesserGameScreenState extends State<GuesserGameScreen> {
  final TextEditingController answerController = TextEditingController();
  static const int totalRound = 5;
  static const int roundSeconds = 30;
  int currentRound = 1;
  int remainingSeconds = roundSeconds;
  late int score;
  Timer? roundTimer;

  bool showAnswerEffect = false;
  bool answerWasCorrect = true;
  bool isSubmittingAnswer = false;
  bool timerStarted = false;
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    score = widget.guesserName == widget.firstPlayerName ? widget.firstPlayerScore : widget.secondPlayerScore;

    webRTCService.onVideoReceived = (String localFilePath) {
      if (mounted) {
        _initVideoPlayer(localFilePath);
        _startRoundTimer();
      }
    };
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    answerController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  void _startRoundTimer() {
    if (timerStarted) return;
    timerStarted = true;
    roundTimer?.cancel();
    roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (remainingSeconds <= 1) {
        setState(() => remainingSeconds = 0);
        _finishRound(isCorrect: false);
        return;
      }
      setState(() => remainingSeconds -= 1);
    });
  }

  void _initVideoPlayer(String localFilePath) {
    if (videoController != null) return;
    videoController = VideoPlayerController.file(File(localFilePath))
      ..initialize().then((_) {
        setState(() {});
        videoController!.setLooping(true);
        videoController!.play();
      });
  }

  Future<void> _submitAnswer(String actualCorrectAnswer) async {
    if (isSubmittingAnswer) return;
    final answer = answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('정답을 입력해주세요.')));
      return;
    }
    final isCorrect = true;;
    await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).update({'status': 'round_completed'});
    await _finishRound(isCorrect: isCorrect);
  }

  Future<void> _finishRound({required bool isCorrect}) async {
    if (isSubmittingAnswer) return;
    isSubmittingAnswer = true;
    roundTimer?.cancel();
    final nextScore = isCorrect ? score + 1 : score;
    await _showAnswerResultEffect(isCorrect);
    if (!mounted) return;
    _moveToNextRound(nextScore);
  }

  Future<void> _showAnswerResultEffect(bool isCorrect) async {
    setState(() { answerWasCorrect = isCorrect; showAnswerEffect = true; });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => showAnswerEffect = false);
  }

  void _moveToNextRound(int nextScore) {
    final updatedFirstPlayerScore = widget.guesserName == widget.firstPlayerName ? nextScore : widget.firstPlayerScore;
    final updatedSecondPlayerScore = widget.guesserName == widget.secondPlayerName ? nextScore : widget.secondPlayerScore;

    if (currentRound >= totalRound) {
      setState(() => isSubmittingAnswer = false);
      
      // 💡 [핵심 수정 구간] 1턴이면 공수 교대, 2턴이면 최종 결과창으로 이동
      if (widget.attackTurn == 1) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => RoleSwapScreen(
              previousSignerName: widget.signerName,
              previousGuesserName: widget.guesserName,
              nextPlayerIsSigner: false, // 다음 턴에는 현재 정답자가 표현자가 됨
              attackTurn: 2, 
              firstPlayerName: widget.firstPlayerName,
              secondPlayerName: widget.secondPlayerName,
              firstPlayerScore: updatedFirstPlayerScore,
              secondPlayerScore: updatedSecondPlayerScore,
              roomCode: widget.roomCode,
              roundWords: widget.roundWords, 
            )
          )
        );
      } else {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              firstPlayerName: widget.firstPlayerName, 
              secondPlayerName: widget.secondPlayerName, 
              firstPlayerScore: updatedFirstPlayerScore, 
              secondPlayerScore: updatedSecondPlayerScore
            )
          )
        );
      }
      return;
    }

    setState(() {
      score = nextScore;
      currentRound += 1;
      answerController.clear();
      remainingSeconds = roundSeconds;
      isSubmittingAnswer = false;
      timerStarted = false;
      videoController?.dispose();
      videoController = null;
    });

    FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).update({'status': 'playing'});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final roomData = snapshot.data!.data() as Map<String, dynamic>;
        final status = roomData['status'] ?? 'playing';
        final actualCorrectAnswer = roomData['correctAnswer'] ?? '';

        return Scaffold(
          backgroundColor: const Color(0xFFF7F6FF),
          appBar: AppBar(backgroundColor: const Color(0xFFF7F6FF), elevation: 0, centerTitle: true, title: const Text('정답자 화면', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)))),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _StatusBox(title: '라운드', value: '$currentRound / $totalRound', icon: Icons.flag)),
                          const SizedBox(width: 12),
                          Expanded(child: _StatusBox(title: '남은 시간', value: '$remainingSeconds초', icon: Icons.timer)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _StatusBox(title: '현재 점수', value: '$score점', icon: Icons.stars),
                      const SizedBox(height: 24),
                      Text('${widget.guesserName}님, 정답을 맞혀보세요', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text('${widget.signerName}님의 수어 동작을 보고 정답을 입력해주세요.', style: const TextStyle(fontSize: 15, color: Color(0xFF77778A)), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity, height: 300,
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(28)),
                        clipBehavior: Clip.antiAlias,
                        child: status == 'playing' 
                            ? const Center(child: Text('상대방이 촬영 중입니다...', style: TextStyle(color: Colors.white)))
                            : (videoController != null && videoController!.value.isInitialized
                                ? VideoPlayer(videoController!)
                                : const Center(child: CircularProgressIndicator(color: Colors.white))),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: answerController,
                        enabled: !isSubmittingAnswer && status == 'waiting_for_answer',
                        decoration: InputDecoration(hintText: '정답을 입력하세요', prefixIcon: const Icon(Icons.edit, color: Color(0xFF6C63FF)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
                      ),
                      const SizedBox(height: 22),
                      _PrimaryButton(
                        text: status == 'playing' ? '영상 도착 대기 중...' : '정답 제출',
                        icon: Icons.send,
                        enabled: !isSubmittingAnswer && status == 'waiting_for_answer' && videoController != null,
                        onTap: () => _submitAnswer(actualCorrectAnswer),
                      ),
                    ],
                  ),
                ),
                _AnswerResultOverlay(visible: showAnswerEffect, isCorrect: answerWasCorrect),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 💡 중요: 이 클래스가 _GuesserGameScreenState 클래스 밖(아래)에 정의되어 있어야 합니다!
class _AnswerResultOverlay extends StatelessWidget {
  final bool visible; final bool isCorrect;
  const _AnswerResultOverlay({required this.visible, required this.isCorrect});
  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF1CA56F) : const Color(0xFFE25B5B);
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0, duration: const Duration(milliseconds: 180),
        child: Container(
          color: Colors.black.withValues(alpha: 0.42),
          child: Center(
            child: AnimatedScale(
              scale: visible ? 1 : 0.86, duration: const Duration(milliseconds: 220), curve: Curves.easeOutBack,
              child: Container(
                width: 240, padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: color, size: 72), 
                    const SizedBox(height: 16), 
                    Text(isCorrect ? '정답입니다!' : '틀렸습니다', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}