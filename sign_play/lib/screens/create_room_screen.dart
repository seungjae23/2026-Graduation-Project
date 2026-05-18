part of sign_play;

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  @override
  void dispose() {
    roomNameController.dispose();
    nicknameController.dispose();
    super.dispose();
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
          '방 만들기',
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
              const Text(
                '새 게임 방을\n만들어볼까요?',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E3A),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                '친구가 참가할 수 있는 방을 만들고\n수어 제스처 게임을 시작해보세요.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF77778A),
                ),
              ),

              const SizedBox(height: 32),

              _InputBox(
                label: '방 이름',
                hintText: '예: 수어 배틀 하실분?',
                icon: Icons.meeting_room,
                controller: roomNameController,
              ),

              const SizedBox(height: 18),

              _InputBox(
                label: '닉네임',
                hintText: '예: Player A',
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
                      '게임 진행 방식',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E3A),
                      ),
                    ),

                    SizedBox(height: 16),

                    _RuleItem(number: '1', text: 'A가 먼저 5라운드 동안 수어를 표현해요.'),

                    SizedBox(height: 12),

                    _RuleItem(number: '2', text: 'B는 A의 영상을 보고 정답을 입력해요.'),

                    SizedBox(height: 12),

                    _RuleItem(number: '3', text: '5라운드가 끝나면 B가 표현자로 바뀌어요.'),

                    SizedBox(height: 12),

                    _RuleItem(number: '4', text: '정답을 많이 맞힌 플레이어가 승리해요.'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _PrimaryButton(
                text: '방 생성하기',
                icon: Icons.add,
                onTap: () {
                  final nickname = nicknameController.text.trim();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WaitingRoomScreen(
                        hostNickname: nickname.isEmpty ? 'Player A' : nickname,
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
    );
  }
}
