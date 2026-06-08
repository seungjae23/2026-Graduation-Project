part of sign_play;

class WaitingRoomScreen extends StatefulWidget {
  final String hostNickname;
  final String? roomCode;
  final String? guestNickname;
  final bool isHost;

  const WaitingRoomScreen({
    super.key,
    required this.hostNickname,
    this.roomCode,
    this.guestNickname,
    this.isHost = true,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  late final String roomCode;
  bool hasMovedToGame = false;
  bool isStartingGame = false;
  bool hasReleasedGuestSlot = false;

  @override
  void initState() {
    super.initState();
    roomCode = widget.roomCode ?? generateRoomCode();
  }

  @override
  void dispose() {
    _releaseGuestSlotIfNeeded();
    super.dispose();
  }

  void _releaseGuestSlotIfNeeded() {
    final guestNickname = widget.guestNickname;

    if (widget.isHost ||
        hasMovedToGame ||
        hasReleasedGuestSlot ||
        guestNickname == null ||
        guestNickname.isEmpty) {
      return;
    }

    hasReleasedGuestSlot = true;

    roomDocument(roomCode).get().then((snapshot) async {
      final roomData = snapshot.data();

      if (!snapshot.exists || roomData == null) {
        return;
      }

      final status = roomData['status'] as String? ?? roomStatusWaiting;
      final currentGuest = roomData['playerB'] as String? ?? '';

      if (status != roomStatusWaiting || currentGuest != guestNickname) {
        return;
      }

      await snapshot.reference.update({
        'playerB': '',
        'guestLeftAt': FieldValue.serverTimestamp(),
      });
    }).catchError((_) {});
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
          builder: (context) => TurnIntroScreen(
            attackerName: gameState.signerName,
            guesserName: gameState.guesserName,
            isSigner: widget.isHost
                ? gameState.signerName == gameState.firstPlayerName
                : gameState.signerName == gameState.secondPlayerName,
            attackTurn: gameState.attackTurn,
            firstPlayerName: gameState.firstPlayerName,
            secondPlayerName: gameState.secondPlayerName,
            firstPlayerScore: gameState.firstPlayerScore,
            secondPlayerScore: gameState.secondPlayerScore,
            roomCode: roomCode,
            totalRounds: gameState.totalRounds,
            roundWords: gameState.roundWords,
          ),
        ),
      );
    });
  }

  Future<void> _copyRoomCode() async {
    await Clipboard.setData(ClipboardData(text: roomCode));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('방 코드가 클립보드에 복사되었습니다.')),
    );
  }

  Future<void> _startGame({
    required String hostNickname,
    required String guestNickname,
    required int totalRounds,
  }) async {
    setState(() {
      isStartingGame = true;
    });

    try {
      final latestRoomSnapshot = await roomDocument(roomCode).get();
      final latestRoomData = latestRoomSnapshot.data();
      final latestStatus =
          latestRoomData?['status'] as String? ?? roomStatusWaiting;
      final latestGuest = latestRoomData?['playerB'] as String? ?? '';

      if (!latestRoomSnapshot.exists ||
          latestStatus != roomStatusWaiting ||
          latestGuest.isEmpty ||
          latestGuest != guestNickname) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('참가자가 대기방을 나갔습니다.')),
        );
        return;
      }

      await startSyncedGame(
        roomCode: roomCode,
        firstPlayerName: hostNickname,
        secondPlayerName: latestGuest,
        totalRounds: totalRounds,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게임 시작에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isStartingGame = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomStream = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomCode)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '대기방',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E3A),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: roomStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('대기방 정보를 불러오지 못했습니다.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final roomSnapshot = snapshot.data;

          if (roomSnapshot == null || !roomSnapshot.exists) {
            return const Center(
              child: Text('존재하지 않는 방입니다.'),
            );
          }

          final roomData = roomSnapshot.data() ?? {};
          final hostNickname =
              roomData['hostNickname'] as String? ?? widget.hostNickname;
          final guestNickname =
              roomData['playerB'] as String? ?? widget.guestNickname ?? '';
          final status = roomData['status'] as String? ?? 'waiting';
          final hasGuest = guestNickname.isNotEmpty;
          final gameState = gameStateFromRoomData(roomData);
          final totalRounds =
              gameState?.totalRounds ?? roundCountFromRoomData(roomData);

          if (status == roomStatusPlaying && hasGuest && gameState != null) {
            _moveToGameIfNeeded(gameState);
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isHost
                          ? '친구가 참가하면\n게임을 시작할 수 있어요'
                          : '방에 참가했어요\n게임 시작을 기다려요',
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E3A),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.isHost
                          ? '아래 방 코드를 친구에게 공유해주세요.'
                          : '입장한 방 코드와 참가 정보를 확인해주세요.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF77778A),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                            '방 코드',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            roomCode,
                            style: const TextStyle(
                              fontSize: 36,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Material(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _copyRoomCode,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.copy,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '코드 복사',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      '참가 플레이어',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E3A),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _PlayerCard(
                      playerName: hostNickname,
                      role: '방장',
                      status: '준비 완료',
                      icon: Icons.person,
                      isReady: true,
                    ),

                    const SizedBox(height: 14),

                    _PlayerCard(
                      playerName: hasGuest ? guestNickname : 'Player B',
                      role: '참가자',
                      status: hasGuest ? '준비 완료' : '참가 대기 중',
                      icon: hasGuest ? Icons.person : Icons.person_outline,
                      isReady: hasGuest,
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '이번 게임 규칙',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E2E3A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A가 먼저 $totalRounds라운드 동안 수어를 표현하고,\nB가 정답을 맞혀 점수를 얻습니다.\n이후 B가 $totalRounds라운드 동안 표현자로 바뀝니다.',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF77778A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _PrimaryButton(
                      text: widget.isHost
                          ? hasGuest
                              ? isStartingGame
                                  ? '게임 시작 중...'
                                  : '게임 시작하기'
                              : '참가자를 기다리는 중'
                          : '방장이 게임을 시작하기를 기다리는 중',
                      icon: widget.isHost ? Icons.play_arrow : Icons.hourglass_top,
                      enabled: widget.isHost && hasGuest && !isStartingGame,
                      onTap: () {
                        _startGame(
                          hostNickname: hostNickname,
                          guestNickname: guestNickname,
                          totalRounds: totalRounds,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String playerName;
  final String role;
  final String status;
  final IconData icon;
  final bool isReady;

  const _PlayerCard({
    required this.playerName,
    required this.role,
    required this.status,
    required this.icon,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 28),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF77778A),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isReady
                  ? const Color(0xFFE8FFF1)
                  : const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isReady
                    ? const Color(0xFF1CA56F)
                    : const Color(0xFFE09A2B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

