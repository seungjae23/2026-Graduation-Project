part of sign_play;

class RoleSwapScreen extends StatefulWidget {
  final String previousSignerName;
  final String previousGuesserName;
  final bool nextPlayerIsSigner;
  final int attackTurn;
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;
  final String? roomCode;

  const RoleSwapScreen({
    super.key,
    required this.previousSignerName,
    required this.previousGuesserName,
    required this.nextPlayerIsSigner,
    required this.attackTurn,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
    this.roomCode,
  });

  @override
  State<RoleSwapScreen> createState() => _RoleSwapScreenState();
}

class _RoleSwapScreenState extends State<RoleSwapScreen> {
  bool hasMovedToTurnIntro = false;
  bool isOpeningNextTurn = false;

  void _moveToTurnIntroIfNeeded(GameState gameState) {
    if (hasMovedToTurnIntro) {
      return;
    }

    hasMovedToTurnIntro = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TurnIntroScreen(
            attackerName: gameState.signerName,
            guesserName: gameState.guesserName,
            isSigner: widget.nextPlayerIsSigner,
            attackTurn: gameState.attackTurn,
            firstPlayerName: gameState.firstPlayerName,
            secondPlayerName: gameState.secondPlayerName,
            firstPlayerScore: gameState.firstPlayerScore,
            secondPlayerScore: gameState.secondPlayerScore,
            roomCode: widget.roomCode,
            roundWords: gameState.roundWords,
          ),
        ),
      );
    });
  }

  Future<void> _openNextTurn() async {
    final roomCode = widget.roomCode;

    if (roomCode == null) {
      _moveToLocalTurnIntro();
      return;
    }

    setState(() {
      isOpeningNextTurn = true;
    });

    try {
      await openSyncedTurnIntro(roomCode);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다음 턴 준비에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isOpeningNextTurn = false;
        });
      }
    }
  }

  void _moveToLocalTurnIntro() {
    final nextSignerName = widget.previousGuesserName;
    final nextGuesserName = widget.previousSignerName;
    final roundSeedBase =
        widget.roomCode ?? '${widget.firstPlayerName}-${widget.secondPlayerName}';
    final nextRoundWords = generateRoundWords(
      seed: '$roundSeedBase-${widget.attackTurn}',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TurnIntroScreen(
          attackerName: nextSignerName,
          guesserName: nextGuesserName,
          isSigner: widget.nextPlayerIsSigner,
          attackTurn: widget.attackTurn,
          firstPlayerName: widget.firstPlayerName,
          secondPlayerName: widget.secondPlayerName,
          firstPlayerScore: widget.firstPlayerScore,
          secondPlayerScore: widget.secondPlayerScore,
          roomCode: widget.roomCode,
          roundWords: nextRoundWords,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomCode = widget.roomCode;

    if (roomCode != null) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: roomDocument(roomCode).snapshots(),
        builder: (context, snapshot) {
          final gameState = gameStateFromRoomData(snapshot.data?.data());

          if (snapshot.hasError) {
            return const Scaffold(
              backgroundColor: Color(0xFFF7F6FF),
              body: Center(child: Text('게임 정보를 불러오지 못했습니다.')),
            );
          }

          if (!snapshot.hasData || gameState == null) {
            return const Scaffold(
              backgroundColor: Color(0xFFF7F6FF),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (gameState.phase == gamePhaseTurnIntro) {
            _moveToTurnIntroIfNeeded(gameState);
          }

          if (gameState.phase == gamePhaseFinished) {
            _moveToResultIfNeeded(gameState);
          }

          return _buildContent(gameState: gameState);
        },
      );
    }

    return _buildContent();
  }

  void _moveToResultIfNeeded(GameState gameState) {
    if (hasMovedToTurnIntro) {
      return;
    }

    hasMovedToTurnIntro = true;

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

  Widget _buildContent({GameState? gameState}) {
    final nextSignerName = gameState?.signerName ?? widget.previousGuesserName;
    final nextGuesserName = gameState?.guesserName ?? widget.previousSignerName;
    final nextRole = widget.nextPlayerIsSigner ? '표현자' : '정답자';
    final firstPlayerName = gameState?.firstPlayerName ?? widget.firstPlayerName;
    final secondPlayerName =
        gameState?.secondPlayerName ?? widget.secondPlayerName;
    final firstPlayerScore =
        gameState?.firstPlayerScore ?? widget.firstPlayerScore;
    final secondPlayerScore =
        gameState?.secondPlayerScore ?? widget.secondPlayerScore;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '공수교대',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E3A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              const Center(
                child: Text(
                  '공수교대!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  '첫 번째 5라운드가 끝났어요.\n이제 $nextSignerName님이 수어를 표현합니다.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF77778A),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    _TurnInfoItem(
                      icon: Icons.sign_language,
                      title: '다음 표현자',
                      value: nextSignerName,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.edit,
                      title: '다음 정답자',
                      value: nextGuesserName,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: widget.nextPlayerIsSigner
                          ? Icons.sign_language
                          : Icons.edit,
                      title: '내 다음 역할',
                      value: nextRole,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.stars,
                      title: firstPlayerName,
                      value: '$firstPlayerScore점',
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.stars,
                      title: secondPlayerName,
                      value: '$secondPlayerScore점',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _PrimaryButton(
                text: isOpeningNextTurn
                    ? '다음 턴 준비 중...'
                    : widget.nextPlayerIsSigner
                    ? '표현자 턴 시작'
                    : '정답자 턴 시작',
                icon: widget.nextPlayerIsSigner ? Icons.sign_language : Icons.edit,
                enabled: !isOpeningNextTurn,
                onTap: _openNextTurn,
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
