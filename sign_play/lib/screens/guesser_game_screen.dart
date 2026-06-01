part of sign_play;

class GuesserGameScreen extends StatefulWidget {
  final String guesserName;
  final String signerName;
  final int attackTurn;
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;
  final String? correctAnswer;
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
    this.correctAnswer,
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

  @override
  void initState() {
    super.initState();
    score = widget.guesserName == widget.firstPlayerName
        ? widget.firstPlayerScore
        : widget.secondPlayerScore;
    _startRoundTimer();
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    answerController.dispose();
    super.dispose();
  }

  void _startRoundTimer() {
    roundTimer?.cancel();
    roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingSeconds <= 1) {
        setState(() {
          remainingSeconds = 0;
        });
        _handleTimeExpired();
        return;
      }

      setState(() {
        remainingSeconds -= 1;
      });
    });
  }

  void _handleTimeExpired() {
    if (isSubmittingAnswer) {
      return;
    }

    _finishRound(isCorrect: false);
  }

  Future<void> _submitAnswer() async {
    if (isSubmittingAnswer) {
      return;
    }

    final answer = answerController.text.trim();

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정답을 입력해주세요.')),
      );
      return;
    }

    await _finishRound(isCorrect: _isCorrectAnswer(answer));
  }

  Future<void> _finishRound({required bool isCorrect}) async {
    if (isSubmittingAnswer) {
      return;
    }

    final nextScore = isCorrect ? score + 1 : score;

    roundTimer?.cancel();

    setState(() {
      isSubmittingAnswer = true;
    });

    await _showAnswerResultEffect(isCorrect);

    if (!mounted) {
      return;
    }

    _moveToNextRound(nextScore);
  }

  bool _isCorrectAnswer(String answer) {
    final correctAnswer = _currentCorrectAnswer;

    if (correctAnswer == null) {
      return true;
    }

    return _normalizeAnswer(answer) == _normalizeAnswer(correctAnswer);
  }

  String? get _currentCorrectAnswer {
    if (widget.correctAnswer != null) {
      return widget.correctAnswer;
    }

    if (currentRound <= widget.roundWords.length) {
      return widget.roundWords[currentRound - 1];
    }

    return null;
  }

  String _normalizeAnswer(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  }

  Future<void> _showAnswerResultEffect(bool isCorrect) async {
    setState(() {
      answerWasCorrect = isCorrect;
      showAnswerEffect = true;
    });

    await Future.delayed(const Duration(milliseconds: 950));

    if (!mounted) {
      return;
    }

    setState(() {
      showAnswerEffect = false;
    });

    await Future.delayed(const Duration(milliseconds: 180));
  }

  void _moveToNextRound(int nextScore) {
    final updatedFirstPlayerScore = widget.guesserName == widget.firstPlayerName
        ? nextScore
        : widget.firstPlayerScore;
    final updatedSecondPlayerScore =
        widget.guesserName == widget.secondPlayerName
            ? nextScore
            : widget.secondPlayerScore;

    if (currentRound >= totalRound) {
      setState(() {
        isSubmittingAnswer = false;
      });

      if (widget.attackTurn >= 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              firstPlayerName: widget.firstPlayerName,
              secondPlayerName: widget.secondPlayerName,
              firstPlayerScore: updatedFirstPlayerScore,
              secondPlayerScore: updatedSecondPlayerScore,
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSwapScreen(
            previousSignerName: widget.signerName,
            previousGuesserName: widget.guesserName,
            nextPlayerIsSigner: true,
            attackTurn: widget.attackTurn + 1,
            firstPlayerName: widget.firstPlayerName,
            secondPlayerName: widget.secondPlayerName,
            firstPlayerScore: updatedFirstPlayerScore,
            secondPlayerScore: updatedSecondPlayerScore,
            roomCode: widget.roomCode,
          ),
        ),
      );
      return;
    }

    setState(() {
      score = nextScore;
      currentRound += 1;
      answerController.clear();
      remainingSeconds = roundSeconds;
      isSubmittingAnswer = false;
    });

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
        title: const Text(
          '정답자 화면',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E3A),
          ),
        ),
      ),
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
                      Expanded(
                        child: _StatusBox(
                          title: '라운드',
                          value: '$currentRound / $totalRound',
                          icon: Icons.flag,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatusBox(
                          title: '남은 시간',
                          value: '$remainingSeconds초',
                          icon: Icons.timer,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _StatusBox(
                    title: '현재 점수',
                    value: '$score점',
                    icon: Icons.stars,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '${widget.guesserName}님, 정답을 맞혀보세요',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E3A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${widget.signerName}님의 수어 동작을 보고 정답을 입력해주세요.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF77778A),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2E3A),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.live_tv,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '상대방 실시간 영상 영역',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '나중에 WebRTC 영상 뷰어가 들어갈 자리',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '정답 입력',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E3A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: answerController,
                    enabled: !isSubmittingAnswer,
                    decoration: InputDecoration(
                      hintText: '정답을 입력하세요',
                      prefixIcon: const Icon(
                        Icons.edit,
                        color: Color(0xFF6C63FF),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _PrimaryButton(
                    text: '정답 제출',
                    icon: Icons.send,
                    enabled: !isSubmittingAnswer,
                    onTap: _submitAnswer,
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
                          '정답자 안내',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2E3A),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '상대방의 수어 동작을 보고 제한 시간 안에 정답을 입력하세요.\n정답을 맞히면 점수가 올라갑니다.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF77778A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
            _AnswerResultOverlay(
              visible: showAnswerEffect,
              isCorrect: answerWasCorrect,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerResultOverlay extends StatelessWidget {
  final bool visible;
  final bool isCorrect;

  const _AnswerResultOverlay({
    required this.visible,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? const Color(0xFF1CA56F)
        : const Color(0xFFE25B5B);
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final title = isCorrect ? '정답입니다!' : '틀렸습니다';
    final subtitle = isCorrect ? '+1점' : '점수 없음';

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          color: Colors.black.withOpacity(0.42),
          child: Center(
            child: AnimatedScale(
              scale: visible ? 1 : 0.86,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Container(
                width: 240,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E3A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
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
