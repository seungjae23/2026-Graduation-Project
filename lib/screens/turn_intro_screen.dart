part of '../main.dart';

class TurnIntroScreen extends StatelessWidget {
  final String attackerName;
  final String guesserName;
  final bool isSigner;
  final int attackTurn;
  final String? firstPlayerName;
  final String? secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;
  final String? roomCode;
  final List<String> roundWords; // null이 아닌 List로 받도록 수정

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
    required this.roundWords, // 필수값으로 변경하여 데이터 전달 보장
  });

  @override
  Widget build(BuildContext context) {
    final currentPlayerName = isSigner ? attackerName : guesserName;
    final currentRole = isSigner ? '표현자' : '정답자';
    final gameFirstPlayerName = firstPlayerName ?? attackerName;
    final gameSecondPlayerName = secondPlayerName ?? guesserName;

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
                        color: Colors.black.withValues(alpha: 0.10),
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
                  isSigner
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
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    _TurnInfoItem(icon: Icons.sign_language, title: '표현자', value: attackerName),
                    const SizedBox(height: 18),
                    _TurnInfoItem(icon: Icons.edit, title: '정답자', value: guesserName),
                    const SizedBox(height: 18),
                    _TurnInfoItem(icon: isSigner ? Icons.sign_language : Icons.edit, title: '내 역할', value: currentRole),
                    const SizedBox(height: 18),
                    _TurnInfoItem(icon: Icons.swap_horiz, title: '공격 순서', value: '$attackTurn / 2'),
                    const SizedBox(height: 18),
                    _TurnInfoItem(icon: Icons.flag, title: '진행 라운드', value: '총 5라운드'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              isSigner
                  ? _PrimaryButton(
                      text: '표현자 화면 시작',
                      icon: Icons.sign_language,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignerGameScreen(
                              playerName: attackerName,
                              guesserName: guesserName,
                              attackTurn: attackTurn,
                              firstPlayerName: gameFirstPlayerName,
                              secondPlayerName: gameSecondPlayerName,
                              firstPlayerScore: firstPlayerScore,
                              secondPlayerScore: secondPlayerScore,
                              roomCode: roomCode,
                              roundWords: roundWords, // 데이터 전달
                            ),
                          ),
                        );
                      },
                    )
                  : _PrimaryButton(
                      text: '정답자 화면 시작',
                      icon: Icons.edit,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuesserGameScreen(
                              guesserName: guesserName,
                              signerName: attackerName,
                              attackTurn: attackTurn,
                              firstPlayerName: gameFirstPlayerName,
                              secondPlayerName: gameSecondPlayerName,
                              firstPlayerScore: firstPlayerScore,
                              secondPlayerScore: secondPlayerScore,
                              roomCode: roomCode,
                              roundWords: roundWords, // 데이터 전달
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