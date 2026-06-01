part of sign_play;

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController roomCodeController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  bool isJoiningRoom = false;

  @override
  void dispose() {
    roomCodeController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final roomCode = roomCodeController.text.trim().replaceAll(' ', '').toUpperCase();
    final nickname = nicknameController.text.trim();

    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 코드를 입력해주세요.')),
      );
      return;
    }

    if (roomCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6자리 방 코드를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      isJoiningRoom = true;
    });

    try {
      final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomCode);
      final roomSnapshot = await roomRef.get();

      if (!mounted) return;

      if (!roomSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('존재하지 않는 방입니다.')),
        );
        return;
      }

      final roomData = roomSnapshot.data() as Map<String, dynamic>;
      final guestNickname = nickname.isEmpty ? 'Player B' : nickname;
      final currentGuest = roomData['playerB'] as String? ?? '';

      if (currentGuest.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 참가자가 있는 방입니다.')),
        );
        return;
      }

      await roomRef.update({
        'playerB': guestNickname,
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingRoomScreen(
            hostNickname: roomData['hostNickname'] as String? ?? 'Player A',
            roomCode: roomCode,
            guestNickname: guestNickname,
            isHost: false,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 참가에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isJoiningRoom = false;
        });
      }
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
        title: const Text(
          '방 참가하기',
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
                const Text(
                  '친구의 방에\n참가해볼까요?',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  '방장이 공유한 6자리 코드를 입력하고\n대기방으로 이동해보세요.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF77778A),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  '방 코드',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: roomCodeController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Color(0xFF2E2E3A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'A7K2Q9',
                    hintStyle: const TextStyle(
                      letterSpacing: 3,
                      color: Color(0xFFB7B4CC),
                    ),
                    prefixIcon: const Icon(
                      Icons.tag,
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

                const SizedBox(height: 18),

                _InputBox(
                  label: '닉네임',
                  hintText: '예: Player B',
                  icon: Icons.person,
                  controller: nicknameController,
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '참가 순서',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 16),
                      _RuleItem(number: '1', text: '방장이 알려준 방 코드를 입력해요.'),
                      SizedBox(height: 12),
                      _RuleItem(number: '2', text: '게임에서 사용할 닉네임을 정해요.'),
                      SizedBox(height: 12),
                      _RuleItem(number: '3', text: '대기방에서 방장이 게임을 시작할 때까지 기다려요.'),
                    ],
                  ),
                ),

                const SizedBox(height: 34),

                _PrimaryButton(
                  text: isJoiningRoom ? '참가 중...' : '방 참가하기',
                  icon: Icons.login,
                  enabled: !isJoiningRoom,
                  onTap: _joinRoom,
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