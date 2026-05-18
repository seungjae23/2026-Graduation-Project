part of sign_play;

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
    currentWord = _wordForRound(currentRound);
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
    _advanceRound(message: '시간이 끝났어요. 다음 라운드로 넘어갑니다.');
  }

  void _completeRound() {
    _advanceRound(message: '$currentRound라운드 동작을 완료했어요.');
  }

  void _advanceRound({required String message}) {
    if (isAdvancingRound) {
      return;
    }

    isAdvancingRound = true;
    roundTimer?.cancel();

    if (currentRound >= totalRound) {
      if (widget.attackTurn >= 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              firstPlayerName: widget.firstPlayerName,
              secondPlayerName: widget.secondPlayerName,
              firstPlayerScore: widget.firstPlayerScore,
              secondPlayerScore: widget.secondPlayerScore,
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSwapScreen(
            previousSignerName: widget.playerName,
            previousGuesserName: widget.guesserName,
            nextPlayerIsSigner: false,
            attackTurn: widget.attackTurn + 1,
            firstPlayerName: widget.firstPlayerName,
            secondPlayerName: widget.secondPlayerName,
            firstPlayerScore: widget.firstPlayerScore,
            secondPlayerScore: widget.secondPlayerScore,
            roomCode: widget.roomCode,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentRound += 1;
      currentWord = _wordForRound(currentRound);
      remainingSeconds = roundSeconds;
      isAdvancingRound = false;
    });

    _startRoundTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message $currentRound라운드 제시어로 넘어갑니다.')),
    );
  }

  String _wordForRound(int round) {
    if (round <= widget.roundWords.length) {
      return widget.roundWords[round - 1];
    }

    return generateRandomWord();
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
          '표현자 화면',
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

                const SizedBox(height: 24),

                Text(
                  '${widget.playerName}님 차례예요',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  '제시어를 보고 수어 동작을 표현해주세요.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF77778A)),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '제시어',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentWord,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _CameraPreviewPanel(
                  height: 280,
                  overlay: Positioned(
                    left: 18,
                    top: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.42),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            '촬영 중',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.back_hand, color: Color(0xFF6C63FF), size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '손 인식 상태',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E3A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'MediaPipe 연결 전입니다',
                              style: TextStyle(
                                fontSize: 13,
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
                        'AI 동작 가이드',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 14),
                      _GuideText(text: '손이 화면 중앙에 오도록 해주세요.'),
                      SizedBox(height: 8),
                      _GuideText(text: '밝은 곳에서 촬영해주세요.'),
                      SizedBox(height: 8),
                      _GuideText(text: '제시어에 맞는 수어를 천천히 표현해주세요.'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _PrimaryButton(
                  text: '동작 완료',
                  icon: Icons.check,
                  enabled: !isAdvancingRound,
                  onTap: _completeRound,
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
