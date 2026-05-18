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
  bool guestReady = false;

  @override
  void initState() {
    super.initState();
    roomCode = widget.roomCode ?? generateRoomCode();
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
          '대기방',
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
                Text(
                  widget.isHost
                      ? '친구가 참가하면\n게임을 시작할 수 있어요'
                      : '방에 참가했어요\n게임 시작을 기다려요',
                  style: TextStyle(
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
                  style: const TextStyle(fontSize: 15, color: Color(0xFF77778A)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy, size: 18, color: Colors.white),
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
                  playerName: widget.hostNickname,
                  role: '방장',
                  status: '준비중',
                  icon: Icons.person,
                  isReady: false,
                ),

                const SizedBox(height: 14),

                _PlayerCard(
                  playerName: widget.guestNickname ?? 'Player B',
                  role: '참가자',
                  status: widget.guestNickname == null
                      ? '참가 대기 중'
                      : guestReady
                          ? '준비 완료'
                          : '준비중',
                  icon: widget.guestNickname == null
                      ? Icons.person_outline
                      : Icons.person,
                  isReady: guestReady,
                ),

                const SizedBox(height: 28),

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
                        '이번 게임 규칙',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'A가 먼저 5라운드 동안 수어를 표현하고,\nB가 정답을 맞혀 점수를 얻습니다.\n이후 B가 5라운드 동안 표현자로 바뀝니다.',
                        style: TextStyle(
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
                      ? '게임 시작하기'
                      : guestReady
                          ? '준비 완료'
                          : '준비하기',
                  icon: widget.isHost
                      ? Icons.play_arrow
                      : guestReady
                          ? Icons.check
                          : Icons.check_circle_outline,
                  enabled: true,
                  onTap: () {
                    if (!widget.isHost) {
                      if (guestReady) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TurnIntroScreen(
                              attackerName: widget.hostNickname,
                              guesserName: widget.guestNickname ?? 'Player B',
                              isSigner: false,
                              roomCode: roomCode,
                              roundWords: generateRoundWords(
                                seed: '$roomCode-1',
                              ),
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        guestReady = true;
                      });
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TurnIntroScreen(
                          attackerName: widget.hostNickname,
                          guesserName: widget.guestNickname ?? 'Player B',
                          isSigner: true,
                          roomCode: roomCode,
                          roundWords: generateRoundWords(
                            seed: '$roomCode-1',
                          ),
                        ),
                      ),
                    );
                  },
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

