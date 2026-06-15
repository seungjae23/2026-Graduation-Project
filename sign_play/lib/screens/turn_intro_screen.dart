part of sign_play;

class TurnIntroScreen extends StatefulWidget {
  final String attackerName;
  final String guesserName;
  final bool isSigner;
  final int attackTurn;
  final String? firstPlayerName;
  final String? secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;
  final String? roomCode;
  final int? totalRounds;
  final List<String>? roundWords;

  const TurnIntroScreen({
    super.key,
    required this.attackerName,
    this.guesserName = 'Player B',
    required this.isSigner,
    this.attackTurn = 1,
    this.firstPlayerName,
    this.secondPlayerName,
    this.firstPlayerScore = 0,
    this.secondPlayerScore = 0,
    this.roomCode,
    this.totalRounds,
    this.roundWords,
  });

  @override
  State<TurnIntroScreen> createState() => _TurnIntroScreenState();
}

class _TurnIntroScreenState extends State<TurnIntroScreen> {
  bool hasMovedToGame = false;
  bool isStartingTurn = false;

  @override
  void dispose() {
    _abortSyncedGameIfNeeded();
    super.dispose();
  }

  void _abortSyncedGameIfNeeded() {
    final roomCode = widget.roomCode;

    if (roomCode == null || hasMovedToGame) {
      return;
    }

    abortSyncedGame(
      roomCode: roomCode,
      leftPlayerName: _currentPlayerName(),
    ).catchError((_) {});
  }

  String _currentPlayerName([GameState? gameState]) {
    if (widget.isSigner) {
      return gameState?.signerName ?? widget.attackerName;
    }

    return gameState?.guesserName ?? widget.guesserName;
  }

  bool _moveToHomeIfOpponentExited(
    Map<String, dynamic>? roomData,
    GameState? gameState,
  ) {
    if (roomData?['status'] != roomStatusAborted) {
      return false;
    }

    if (hasMovedToGame) {
      return true;
    }

    if (!wasRoomAbortedByOpponent(roomData, _currentPlayerName(gameState))) {
      return false;
    }

    hasMovedToGame = true;
    moveToHomeAfterOpponentExit(
      context,
      message: opponentExitMessage(roomData),
    );
    return true;
  }

  void _moveToGameIfNeeded(GameState gameState) {
    if (hasMovedToGame) {
      return;
    }

    hasMovedToGame = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.isSigner
              ? SignerGameScreen(
                  playerName: gameState.signerName,
                  guesserName: gameState.guesserName,
                  attackTurn: gameState.attackTurn,
                  firstPlayerName: gameState.firstPlayerName,
                  secondPlayerName: gameState.secondPlayerName,
                  firstPlayerScore: gameState.firstPlayerScore,
                  secondPlayerScore: gameState.secondPlayerScore,
                  roomCode: widget.roomCode,
                  totalRounds: gameState.totalRounds,
                  roundWords: gameState.roundWords,
                )
              : GuesserGameScreen(
                  guesserName: gameState.guesserName,
                  signerName: gameState.signerName,
                  attackTurn: gameState.attackTurn,
                  firstPlayerName: gameState.firstPlayerName,
                  secondPlayerName: gameState.secondPlayerName,
                  firstPlayerScore: gameState.firstPlayerScore,
                  secondPlayerScore: gameState.secondPlayerScore,
                  roomCode: widget.roomCode,
                  totalRounds: gameState.totalRounds,
                  roundWords: gameState.roundWords,
                ),
        ),
      );
    });
  }

  Future<void> _toggleReady(bool nextReady) async {
    final roomCode = widget.roomCode;

    if (roomCode == null) {
      _moveToLocalGame();
      return;
    }

    setState(() {
      isStartingTurn = true;
    });

    try {
      await setSyncedTurnReady(
        roomCode: roomCode,
        isSigner: widget.isSigner,
        isReady: nextReady,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('준비 상태 업데이트에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isStartingTurn = false;
        });
      }
    }
  }

  void _moveToLocalGame() {
    final gameFirstPlayerName = widget.firstPlayerName ?? widget.attackerName;
    final gameSecondPlayerName = widget.secondPlayerName ?? widget.guesserName;
    final roundSeedBase =
        widget.roomCode ?? '$gameFirstPlayerName-$gameSecondPlayerName';
    final totalRounds =
        widget.totalRounds ?? roundCountFromWords(widget.roundWords);
    final gameRoundWords =
        widget.roundWords ??
        generateRoundWords(
          count: totalRounds,
          seed: '$roundSeedBase-${widget.attackTurn}',
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget.isSigner
            ? SignerGameScreen(
                playerName: widget.attackerName,
                guesserName: widget.guesserName,
                attackTurn: widget.attackTurn,
                firstPlayerName: gameFirstPlayerName,
                secondPlayerName: gameSecondPlayerName,
                firstPlayerScore: widget.firstPlayerScore,
                secondPlayerScore: widget.secondPlayerScore,
                roomCode: widget.roomCode,
                totalRounds: totalRounds,
                roundWords: gameRoundWords,
              )
            : GuesserGameScreen(
                guesserName: widget.guesserName,
                signerName: widget.attackerName,
                attackTurn: widget.attackTurn,
                firstPlayerName: gameFirstPlayerName,
                secondPlayerName: gameSecondPlayerName,
                firstPlayerScore: widget.firstPlayerScore,
                secondPlayerScore: widget.secondPlayerScore,
                roomCode: widget.roomCode,
                totalRounds: totalRounds,
                roundWords: gameRoundWords,
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
          final roomData = snapshot.data?.data();
          final gameState = gameStateFromRoomData(roomData);

          if (snapshot.hasError) {
            return const Scaffold(
              backgroundColor: Color(0xFFF7F6FF),
              body: Center(child: Text('게임 정보를 불러오지 못했습니다.')),
            );
          }

          if (_moveToHomeIfOpponentExited(roomData, gameState)) {
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

          if (gameState.phase == gamePhasePlaying) {
            _moveToGameIfNeeded(gameState);
          }

          return _buildContent(gameState: gameState);
        },
      );
    }

    return _buildContent();
  }

  Widget _buildContent({GameState? gameState}) {
    final attackerName = gameState?.signerName ?? widget.attackerName;
    final guesserName = gameState?.guesserName ?? widget.guesserName;
    final attackTurn = gameState?.attackTurn ?? widget.attackTurn;
    final totalRounds =
        gameState?.totalRounds ??
        widget.totalRounds ??
        roundCountFromWords(widget.roundWords);
    final currentPlayerName = _currentPlayerName(gameState);
    final currentRole = widget.isSigner ? '표현자' : '정답자';
    final currentPlayerReady = widget.isSigner
        ? (gameState?.signerReady ?? false)
        : (gameState?.guesserReady ?? false);
    final opponentReady = widget.isSigner
        ? (gameState?.guesserReady ?? false)
        : (gameState?.signerReady ?? false);
    final opponentRole = widget.isSigner ? '정답자' : '표현자';
    final readyButtonText = currentPlayerReady
        ? '준비 취소'
        : (widget.isSigner ? '표현자 준비' : '정답자 준비');
    final canMarkReady =
        (gameState == null || gameState.phase == gamePhaseTurnIntro) &&
        !isStartingTurn;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '턴 시작',
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
                    Icons.sign_language,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Center(
                child: Text(
                  '$currentPlayerName님 차례 준비!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  widget.isSigner
                      ? '이번 턴에서는 $attackerName님이 수어를 표현합니다.\n제시어를 확인하고 동작을 시작해주세요.'
                      : '이번 턴에서는 $attackerName님의 수어를 보고\n$guesserName님이 정답을 맞힙니다.',
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ReadyStatusItem(
                      icon: widget.isSigner ? Icons.sign_language : Icons.edit,
                      title: '내 준비 상태',
                      value: currentPlayerReady ? '준비 완료' : '준비 대기 중',
                      isReady: currentPlayerReady,
                    ),
                    const SizedBox(height: 14),
                    _ReadyStatusItem(
                      icon: widget.isSigner ? Icons.edit : Icons.sign_language,
                      title: '상대방 준비 상태',
                      value: opponentReady
                          ? '$opponentRole 준비 완료'
                          : '$opponentRole 준비 대기 중',
                      isReady: opponentReady,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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
                      title: '표현자',
                      value: attackerName,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.edit,
                      title: '정답자',
                      value: guesserName,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: widget.isSigner ? Icons.sign_language : Icons.edit,
                      title: '내 역할',
                      value: currentRole,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.swap_horiz,
                      title: '공격 순서',
                      value: '$attackTurn / 2',
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.flag,
                      title: '진행 라운드',
                      value: '총 $totalRounds라운드',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              if (widget.isSigner)
                _PrimaryButton(
                  text: isStartingTurn ? '준비 중...' : readyButtonText,
                  icon: Icons.sign_language,
                  enabled: canMarkReady,
                  onTap: () => _toggleReady(!currentPlayerReady),
                )
              else
                _PrimaryButton(
                  text: isStartingTurn ? '준비 중...' : readyButtonText,
                  icon: Icons.edit,
                  enabled: canMarkReady,
                  onTap: () => _toggleReady(!currentPlayerReady),
                ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadyStatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isReady;

  const _ReadyStatusItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    final color = isReady
        ? const Color(0xFF1CA56F)
        : const Color(0xFFE09A2B);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF77778A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E3A),
                ),
              ),
            ],
          ),
        ),
        Icon(
          isReady ? Icons.check_circle : Icons.hourglass_top,
          color: color,
          size: 24,
        ),
      ],
    );
  }
}
