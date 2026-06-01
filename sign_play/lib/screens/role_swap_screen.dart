part of sign_play;

class RoleSwapScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final nextSignerName = previousGuesserName;
    final nextGuesserName = previousSignerName;
    final nextRole = nextPlayerIsSigner ? '표현자' : '정답자';
    final roundSeedBase = roomCode ?? '$firstPlayerName-$secondPlayerName';
    final nextRoundWords = generateRoundWords(
      seed: '$roundSeedBase-$attackTurn',
    );

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
                  '$previousSignerName님의 5라운드가 끝났어요.\n이제 $nextSignerName님이 수어를 표현합니다.',
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
                      icon: nextPlayerIsSigner ? Icons.sign_language : Icons.edit,
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
                text: nextPlayerIsSigner ? '표현자 턴 시작' : '정답자 턴 시작',
                icon: nextPlayerIsSigner ? Icons.sign_language : Icons.edit,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TurnIntroScreen(
                        attackerName: nextSignerName,
                        guesserName: nextGuesserName,
                        isSigner: nextPlayerIsSigner,
                        attackTurn: attackTurn,
                        firstPlayerName: firstPlayerName,
                        secondPlayerName: secondPlayerName,
                        firstPlayerScore: firstPlayerScore,
                        secondPlayerScore: secondPlayerScore,
                        roomCode: roomCode,
                        roundWords: nextRoundWords,
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
