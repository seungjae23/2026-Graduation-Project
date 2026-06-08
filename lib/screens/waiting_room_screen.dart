part of '../main.dart';

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

  @override
  void initState() {
    super.initState();
    roomCode = widget.roomCode ?? generateRoomCode();
  }

  // JSON에서 단어 5개 추출
  Future<List<String>> _loadRoundWords() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/words.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      List<String> allWords = [];
      for (var list in data.values) {
        allWords.addAll(List<String>.from(list));
      }
      allWords.shuffle();
      return allWords.take(5).toList();
    } catch (e) {
      return ['사과', '바나나', '포도', '수박', '오렌지']; // 에러 시 기본값
    }
  }

  void _moveToGameIfNeeded({
    required String hostNickname,
    required String guestNickname,
  }) async {
    if (hasMovedToGame) return;
    hasMovedToGame = true;

    final roundWords = await _loadRoundWords();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TurnIntroScreen(
          attackerName: hostNickname,
          guesserName: guestNickname,
          isSigner: widget.isHost,
          roomCode: roomCode,
          roundWords: roundWords,
        ),
      ),
    );
  }

  Future<void> _startGame() async {
    setState(() => isStartingGame = true);
    try {
      await FirebaseFirestore.instance.collection('rooms').doc(roomCode).update({
        'status': 'playing',
        'startedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('게임 시작 실패: $error')));
    } finally {
      if (mounted) setState(() => isStartingGame = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text('대기방', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('rooms').doc(roomCode).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final roomData = snapshot.data!.data() ?? {};
          final hostNickname = roomData['hostNickname'] as String? ?? widget.hostNickname;
          final guestNickname = roomData['playerB'] as String? ?? widget.guestNickname ?? '';
          final status = roomData['status'] as String? ?? 'waiting';
          final hasGuest = guestNickname.isNotEmpty;

          if (status == 'playing' && hasGuest) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _moveToGameIfNeeded(hostNickname: hostNickname, guestNickname: guestNickname);
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isHost ? '친구가 참가하면\n게임을 시작할 수 있어요' : '방에 참가했어요\n게임 시작을 기다려요',
                    style: const TextStyle(fontSize: 28, height: 1.25, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(0xFF6C63FF), borderRadius: BorderRadius.circular(26)),
                    child: Column(
                      children: [
                        const Text('방 코드', style: TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(roomCode, style: const TextStyle(fontSize: 36, letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PlayerCard(playerName: hostNickname, role: '방장', status: '준비 완료', icon: Icons.person, isReady: true),
                  const SizedBox(height: 14),
                  _PlayerCard(playerName: hasGuest ? guestNickname : 'Player B', role: '참가자', status: hasGuest ? '준비 완료' : '참가 대기 중', icon: hasGuest ? Icons.person : Icons.person_outline, isReady: hasGuest),
                  const SizedBox(height: 28),
                  _PrimaryButton(
                    text: widget.isHost ? (hasGuest ? (isStartingGame ? '게임 시작 중...' : '게임 시작하기') : '참가자를 기다리는 중') : '방장이 게임을 시작하기를 기다리는 중',
                    icon: widget.isHost ? Icons.play_arrow : Icons.hourglass_top,
                    enabled: widget.isHost && hasGuest && !isStartingGame,
                    onTap: _startGame,
                  ),
                ],
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

  const _PlayerCard({required this.playerName, required this.role, required this.status, required this.icon, required this.isReady});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: const Color(0xFFF1F0FF), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playerName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)), overflow: TextOverflow.ellipsis),
                Text(role, style: const TextStyle(fontSize: 13, color: Color(0xFF77778A))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: isReady ? const Color(0xFFE8FFF1) : const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(14)),
            child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isReady ? const Color(0xFF1CA56F) : const Color(0xFFE09A2B))),
          ),
        ],
      ),
    );
  }
}