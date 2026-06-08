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
  final int totalRounds;
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
    this.totalRounds = gameDefaultTotalRounds,
    required this.roundWords,
  });

  @override
  State<SignerGameScreen> createState() => _SignerGameScreenState();
}

class _SignerGameScreenState extends State<SignerGameScreen> {
  int currentRound = 1;
  int remainingSeconds = gameRoundSeconds;
  late String currentWord;
  Timer? roundTimer;
  bool isAdvancingRound = false;
  bool hasMovedFromGame = false;
  bool showAnswerEffect = false;
  bool answerWasCorrect = true;
  bool isShowingAnswerEffect = false;
  String? shownAnswerFeedbackKey;

  @override
  void initState() {
    super.initState();
    currentWord = _wordForRound(currentRound);

    if (widget.roomCode == null) {
      _startLocalRoundTimer();
    } else {
      _startSyncedTicker();
    }
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    _abortSyncedGameIfNeeded();
    super.dispose();
  }

  void _abortSyncedGameIfNeeded() {
    final roomCode = widget.roomCode;

    if (roomCode == null || hasMovedFromGame) {
      return;
    }

    abortSyncedGame(
      roomCode: roomCode,
      leftPlayerName: widget.playerName,
    ).catchError((_) {});
  }

  bool _moveToHomeIfOpponentExited(Map<String, dynamic>? roomData) {
    if (roomData?['status'] != roomStatusAborted) {
      return false;
    }

    if (hasMovedFromGame) {
      return true;
    }

    if (!wasRoomAbortedByOpponent(roomData, widget.playerName)) {
      return false;
    }

    hasMovedFromGame = true;
    moveToHomeAfterOpponentExit(
      context,
      message: opponentExitMessage(roomData),
    );
    return true;
  }

  void _startSyncedTicker() {
    roundTimer?.cancel();
    roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {});
    });
  }

  void _startLocalRoundTimer() {
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
        _handleLocalTimeExpired();
        return;
      }

      setState(() {
        remainingSeconds -= 1;
      });
    });
  }

  void _handleLocalTimeExpired() {
    _advanceLocalRound(message: '시간이 끝났어요. 다음 라운드로 넘어갑니다.');
  }

  void _completeLocalRound() {
    _advanceLocalRound(message: '$currentRound라운드 동작을 완료했어요.');
  }

  void _advanceLocalRound({required String message}) {
    if (isAdvancingRound) {
      return;
    }

    isAdvancingRound = true;
    roundTimer?.cancel();

    if (currentRound >= widget.totalRounds) {
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
            totalRounds: widget.totalRounds,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentRound += 1;
      currentWord = _wordForRound(currentRound);
      remainingSeconds = gameRoundSeconds;
      isAdvancingRound = false;
    });

    _startLocalRoundTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message $currentRound라운드 제시어로 넘어갑니다.')),
    );
  }

  void _moveToRoleSwapIfNeeded(GameState gameState) {
    if (hasMovedFromGame) {
      return;
    }

    hasMovedFromGame = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSwapScreen(
            previousSignerName: widget.playerName,
            previousGuesserName: widget.guesserName,
            nextPlayerIsSigner: false,
            attackTurn: gameState.attackTurn,
            firstPlayerName: gameState.firstPlayerName,
            secondPlayerName: gameState.secondPlayerName,
            firstPlayerScore: gameState.firstPlayerScore,
            secondPlayerScore: gameState.secondPlayerScore,
            roomCode: widget.roomCode,
            totalRounds: gameState.totalRounds,
          ),
        ),
      );
    });
  }

  void _moveToResultIfNeeded(GameState gameState) {
    if (hasMovedFromGame) {
      return;
    }

    hasMovedFromGame = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            firstPlayerName: gameState.firstPlayerName,
            secondPlayerName: gameState.secondPlayerName,
            firstPlayerScore: gameState.firstPlayerScore,
            secondPlayerScore: gameState.secondPlayerScore,
          ),
        ),
      );
    });
  }

  bool _showSyncedAnswerEffectIfNeeded(GameState gameState) {
    final feedbackKey = gameState.answerFeedbackKey;

    if (feedbackKey == null) {
      return false;
    }

    if (gameState.lastAnswerAttackTurn != widget.attackTurn) {
      return false;
    }

    if (shownAnswerFeedbackKey == feedbackKey) {
      return isShowingAnswerEffect;
    }

    shownAnswerFeedbackKey = feedbackKey;
    isShowingAnswerEffect = true;
    answerWasCorrect = gameState.lastAnswerCorrect ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      setState(() {
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

      if (!mounted) {
        return;
      }

      setState(() {
        isShowingAnswerEffect = false;
      });
    });

    return true;
  }

  String _wordForRound(int round) {
    if (round <= widget.roundWords.length) {
      return widget.roundWords[round - 1];
    }

    return generateRandomWord();
  }

  @override
  Widget build(BuildContext context) {
    final roomCode = widget.roomCode;

    if (roomCode != null) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: roomDocument(roomCode).snapshots(),
        builder: (context, snapshot) {
          final roomData = snapshot.data?.data();
          final gameState = gameStateFromRoomData(roomData);

          if (snapshot.hasError) {
            return const Scaffold(
              backgroundColor: Color(0xFFF7F6FF),
              body: Center(child: Text('게임 정보를 불러오지 못했습니다.')),
            );
          }

          if (_moveToHomeIfOpponentExited(roomData)) {
            return const Scaffold(
              backgroundColor: Color(0xFFF7F6FF),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || gameState == null) {
            return const Scaffold(
              backgroundColor: Color(0xFFF7F6FF),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final shouldWaitForFeedback = _showSyncedAnswerEffectIfNeeded(
            gameState,
          );

          if (gameState.phase == gamePhaseRoleSwap && !shouldWaitForFeedback) {
            _moveToRoleSwapIfNeeded(gameState);
          }

          if (gameState.phase == gamePhaseFinished && !shouldWaitForFeedback) {
            _moveToResultIfNeeded(gameState);
          }

          final syncedRemainingSeconds =
              gameState.phase == gamePhasePlaying
              ? gameState.remainingSeconds(DateTime.now())
              : gameRoundSeconds;

          return _buildScaffold(
            currentRound: gameState.currentRound,
            remainingSeconds: syncedRemainingSeconds,
            currentWord: gameState.currentWord,
            totalRounds: gameState.totalRounds,
          );
        },
      );
    }

    return _buildScaffold(
      currentRound: currentRound,
      remainingSeconds: remainingSeconds,
      currentWord: currentWord,
      totalRounds: widget.totalRounds,
    );
  }

  Widget _buildScaffold({
    required int currentRound,
    required int remainingSeconds,
    required String currentWord,
    required int totalRounds,
  }) {
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
        child: Stack(
          children: [
            SingleChildScrollView(
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
                        value: '$currentRound / $totalRounds',
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
              ],
            ),
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
