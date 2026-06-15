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
  final int totalRounds;
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
    this.totalRounds = gameDefaultTotalRounds,
    required this.roundWords,
  });

  @override
  State<GuesserGameScreen> createState() => _GuesserGameScreenState();
}

class _GuesserGameScreenState extends State<GuesserGameScreen> {
  final TextEditingController answerController = TextEditingController();
  final WebRTCService webRTCService = WebRTCService();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool isWebRTCReady = false;

  int currentRound = 1;
  int remainingSeconds = gameRoundSeconds;
  late int score;
  Timer? roundTimer;
  bool showAnswerEffect = false;
  bool answerWasCorrect = true;
  bool isSubmittingAnswer = false;
  bool hasMovedFromGame = false;
  String? syncedRoundKey;

  @override
  void initState() {
    super.initState();
    score = widget.guesserName == widget.firstPlayerName
        ? widget.firstPlayerScore
        : widget.secondPlayerScore;
    _startWebRTCIfNeeded();

    if (widget.roomCode == null) {
      _startLocalRoundTimer();
    } else {
      _startSyncedTicker();
    }
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    answerController.dispose();
    webRTCService.dispose();
    remoteRenderer.dispose();
    _abortSyncedGameIfNeeded();
    super.dispose();
  }

  Future<void> _startWebRTCIfNeeded() async {
    final roomCode = widget.roomCode;

    if (roomCode == null) {
      return;
    }

    try {
      await remoteRenderer.initialize();
      await webRTCService.startGuesser(roomCode, remoteRenderer);

      if (!mounted) {
        return;
      }

      setState(() {
        isWebRTCReady = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isWebRTCReady = false;
      });
    }
  }

  void _abortSyncedGameIfNeeded() {
    final roomCode = widget.roomCode;

    if (roomCode == null || hasMovedFromGame) {
      return;
    }

    abortSyncedGame(
      roomCode: roomCode,
      leftPlayerName: widget.guesserName,
    ).catchError((_) {});
  }

  bool _moveToHomeIfOpponentExited(Map<String, dynamic>? roomData) {
    if (roomData?['status'] != roomStatusAborted) {
      return false;
    }

    if (hasMovedFromGame) {
      return true;
    }

    if (!wasRoomAbortedByOpponent(roomData, widget.guesserName)) {
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
    if (isSubmittingAnswer) {
      return;
    }

    _finishLocalRound(isCorrect: false);
  }

  void _handleSyncedTimeExpired(GameState gameState) {
    if (isSubmittingAnswer) {
      return;
    }

    _finishSyncedRound(gameState: gameState, isCorrect: false);
  }

  Future<void> _submitLocalAnswer() async {
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

    await _finishLocalRound(isCorrect: _isCorrectAnswer(answer));
  }

  Future<void> _submitSyncedAnswer(GameState gameState) async {
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

    await _finishSyncedRound(
      gameState: gameState,
      isCorrect: _normalizeAnswer(answer) == _normalizeAnswer(gameState.currentWord),
    );
  }

  Future<void> _finishLocalRound({required bool isCorrect}) async {
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

    _moveToLocalNextRound(nextScore);
  }

  Future<void> _finishSyncedRound({
    required GameState gameState,
    required bool isCorrect,
  }) async {
    final roomCode = widget.roomCode;

    if (roomCode == null || isSubmittingAnswer) {
      return;
    }

    final nextFirstPlayerScore =
        isCorrect && gameState.guesserName == gameState.firstPlayerName
        ? gameState.firstPlayerScore + 1
        : gameState.firstPlayerScore;
    final nextSecondPlayerScore =
        isCorrect && gameState.guesserName == gameState.secondPlayerName
        ? gameState.secondPlayerScore + 1
        : gameState.secondPlayerScore;

    setState(() {
      isSubmittingAnswer = true;
    });

    await _showAnswerResultEffect(isCorrect);

    if (!mounted) {
      return;
    }

    try {
      await completeSyncedRound(
        roomCode: roomCode,
        expectedAttackTurn: gameState.attackTurn,
        expectedRound: gameState.currentRound,
        firstPlayerScore: nextFirstPlayerScore,
        secondPlayerScore: nextSecondPlayerScore,
        answerWasCorrect: isCorrect,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정답 제출에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingAnswer = false;
        });
      }
    }
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

  void _moveToLocalNextRound(int nextScore) {
    final updatedFirstPlayerScore = widget.guesserName == widget.firstPlayerName
        ? nextScore
        : widget.firstPlayerScore;
    final updatedSecondPlayerScore =
        widget.guesserName == widget.secondPlayerName
        ? nextScore
        : widget.secondPlayerScore;

    if (currentRound >= widget.totalRounds) {
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
            totalRounds: widget.totalRounds,
          ),
        ),
      );
      return;
    }

    setState(() {
      score = nextScore;
      currentRound += 1;
      answerController.clear();
      remainingSeconds = gameRoundSeconds;
      isSubmittingAnswer = false;
    });

    _startLocalRoundTimer();
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
            previousSignerName: widget.signerName,
            previousGuesserName: widget.guesserName,
            nextPlayerIsSigner: true,
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

  void _syncRoundInput(GameState gameState) {
    final nextRoundKey = '${gameState.attackTurn}-${gameState.currentRound}';

    if (syncedRoundKey == nextRoundKey) {
      return;
    }

    syncedRoundKey = nextRoundKey;
    answerController.clear();
    isSubmittingAnswer = false;
  }

  int _scoreForGuesser(GameState gameState) {
    if (gameState.guesserName == gameState.firstPlayerName) {
      return gameState.firstPlayerScore;
    }

    return gameState.secondPlayerScore;
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

          _syncRoundInput(gameState);

          if (gameState.phase == gamePhaseRoleSwap) {
            _moveToRoleSwapIfNeeded(gameState);
          }

          if (gameState.phase == gamePhaseFinished) {
            _moveToResultIfNeeded(gameState);
          }

          final syncedRemainingSeconds =
              gameState.phase == gamePhasePlaying
              ? gameState.remainingSeconds(DateTime.now())
              : gameRoundSeconds;

          if (syncedRemainingSeconds == 0 &&
              gameState.phase == gamePhasePlaying) {
            _handleSyncedTimeExpired(gameState);
          }

          return _buildScaffold(
            currentRound: gameState.currentRound,
            remainingSeconds: syncedRemainingSeconds,
            score: _scoreForGuesser(gameState),
            signerName: gameState.signerName,
            guesserName: gameState.guesserName,
            totalRounds: gameState.totalRounds,
            onSubmitAnswer: () => _submitSyncedAnswer(gameState),
          );
        },
      );
    }

    return _buildScaffold(
      currentRound: currentRound,
      remainingSeconds: remainingSeconds,
      score: score,
      signerName: widget.signerName,
      guesserName: widget.guesserName,
      totalRounds: widget.totalRounds,
      onSubmitAnswer: _submitLocalAnswer,
    );
  }

  Widget _buildScaffold({
    required int currentRound,
    required int remainingSeconds,
    required int score,
    required String signerName,
    required String guesserName,
    required int totalRounds,
    required VoidCallback onSubmitAnswer,
  }) {
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

                  const SizedBox(height: 16),

                  _StatusBox(
                    title: '현재 점수',
                    value: '$score점',
                    icon: Icons.stars,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '$guesserName님, 정답을 맞혀보세요',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E3A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '$signerName님의 수어 동작을 보고 정답을 입력해주세요.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF77778A),
                    ),
                  ),

                  const SizedBox(height: 24),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      color: const Color(0xFF2E2E3A),
                      child: isWebRTCReady
                          ? RTCVideoView(
                              remoteRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            )
                          : const _CameraPreviewMessage(
                              icon: Icons.live_tv,
                              title: '영상 연결 대기 중',
                              description: '상대방의 실시간 영상을 연결하고 있어요.',
                            ),
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
                    text: isSubmittingAnswer ? '제출 중...' : '정답 제출',
                    icon: Icons.send,
                    enabled: !isSubmittingAnswer,
                    onTap: onSubmitAnswer,
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
