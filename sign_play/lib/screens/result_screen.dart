part of sign_play;

class ResultScreen extends StatelessWidget {
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;

  const ResultScreen({
    super.key,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
  });

  @override
  Widget build(BuildContext context) {
    final isDraw = firstPlayerScore == secondPlayerScore;
    final winnerName = firstPlayerScore > secondPlayerScore
        ? firstPlayerName
        : secondPlayerName;
    final resultTitle = isDraw ? '무승부!' : '$winnerName 승리!';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '게임 결과',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E3A),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
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
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Center(
                child: Text(
                  resultTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  '각자 한 번씩 공격과 수비를 마쳤어요.\n최종 점수를 확인해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                      icon: Icons.person,
                      title: firstPlayerName,
                      value: '$firstPlayerScore점',
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.person,
                      title: secondPlayerName,
                      value: '$secondPlayerScore점',
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.flag,
                      title: '결과',
                      value: isDraw ? '무승부' : '$winnerName 승리',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              _PrimaryButton(
                text: '홈으로 돌아가기',
                icon: Icons.home,
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
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