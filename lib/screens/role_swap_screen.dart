part of '../main.dart';

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
  final List<String> roundWords; // 상위에서 결정된 제시어 목록을 전달받음

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
    required this.roundWords,
  });

  @override
  Widget build(BuildContext context) {
    // 역할 교대 정보 설정
    final nextSignerName = nextPlayerIsSigner ? previousGuesserName : previousSignerName;
    final nextGuesserName = nextPlayerIsSigner ? previousSignerName : previousGuesserName;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.swap_horiz, size: 80, color: Color(0xFF6C63FF)),
              const SizedBox(height: 24),
              const Text(
                '공수 교대!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '역할을 바꿔서 진행합니다.\n$nextSignerName님이 표현자가 됩니다.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF77778A)),
              ),
              const SizedBox(height: 40),
              _PrimaryButton(
                text: '다음 턴 준비하기',
                icon: Icons.arrow_forward,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TurnIntroScreen(
                        attackerName: nextSignerName,
                        guesserName: nextGuesserName,
                        isSigner: true, // 다음 턴 준비이므로 표현자 시점으로 시작
                        attackTurn: attackTurn,
                        firstPlayerName: firstPlayerName,
                        secondPlayerName: secondPlayerName,
                        firstPlayerScore: firstPlayerScore,
                        secondPlayerScore: secondPlayerScore,
                        roomCode: roomCode,
                        roundWords: roundWords, // 데이터 그대로 전달
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}