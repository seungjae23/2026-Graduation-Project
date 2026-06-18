part of '../main.dart';

class SignerGameScreen extends StatefulWidget {
  final String playerName;
  final String guesserName;
  final int attackTurn;
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;
  final String roomCode; 
  final List<String> roundWords;

  const SignerGameScreen({
    super.key,
    required this.playerName,
    required this.guesserName,
    required this.attackTurn,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
    required this.roomCode,
    required this.roundWords,
  });

  @override
  State<SignerGameScreen> createState() => _SignerGameScreenState();
}

class _SignerGameScreenState extends State<SignerGameScreen> {
  static const int totalRound = 5;
  static const int roundSeconds = 30;
  int currentRound = 1;
  int remainingSeconds = roundSeconds;
  
  late String currentWord;
  late List<String> _gameWords; // 💡 여기서 이번 게임에 쓸 랜덤 단어들을 보관합니다.
  
  Timer? roundTimer;
  bool isAdvancingRound = false;

  @override
  void initState() {
    super.initState();
    // 💡 이전 화면에서 넘어온 단어를 무시하고, WordService로 무조건 5개를 새로 랜덤 뽑기!
    _gameWords = WordService.getRandomWords(totalRound);
    currentWord = _gameWords.isNotEmpty ? _gameWords[0] : "준비";
    _startRoundTimer();
  }

  @override
  void dispose() {
    roundTimer?.cancel();
    super.dispose();
  }

  void _startRoundTimer() {
    roundTimer?.cancel();
    roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (remainingSeconds <= 1) {
        setState(() => remainingSeconds = 0);
        timer.cancel();
        _advanceRound(message: '시간 초과! 다음 라운드로 넘어갑니다.');
        return;
      }
      setState(() => remainingSeconds -= 1);
    });
  }

  void _advanceRound({required String message}) {
    if (isAdvancingRound) return;
    isAdvancingRound = true;
    roundTimer?.cancel();

    print("📢 게임 알림: $message");

    if (currentRound >= totalRound) {
      if (widget.attackTurn == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RoleSwapScreen(
              previousSignerName: widget.playerName,
              previousGuesserName: widget.guesserName,
              nextPlayerIsSigner: true,
              attackTurn: 2,
              firstPlayerName: widget.firstPlayerName,
              secondPlayerName: widget.secondPlayerName,
              firstPlayerScore: widget.firstPlayerScore,
              secondPlayerScore: widget.secondPlayerScore,
              roomCode: widget.roomCode,
              roundWords: _gameWords, // 뽑아둔 랜덤 단어를 다음 화면으로 넘겨줍니다.
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              firstPlayerName: widget.firstPlayerName,
              secondPlayerName: widget.secondPlayerName,
              firstPlayerScore: widget.firstPlayerScore,
              secondPlayerScore: widget.secondPlayerScore,
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      currentRound += 1;
      // 💡 다음 라운드로 넘어갈 때, 우리가 랜덤으로 뽑아둔 리스트에서 단어를 가져옵니다.
      currentWord = (currentRound - 1 < _gameWords.length)
          ? _gameWords[currentRound - 1]
          : "종료";
      remainingSeconds = roundSeconds;
      isAdvancingRound = false;
    });

    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomCode)
        .update({'status': 'playing'});
    
    _startRoundTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text('표현자 화면',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomCode)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final roomData = snapshot.data!.data() as Map<String, dynamic>?;
          final status = roomData?['status'] ?? 'playing';

          if (status == 'round_completed' && !isAdvancingRound) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => _advanceRound(message: '2P가 정답을 제출했습니다!'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameHeader(
                  currentRound: currentRound,
                  totalRound: totalRound,
                  remainingSeconds: remainingSeconds,
                ),
                const SizedBox(height: 24),
                Text('${widget.playerName}님 차례예요',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E3A))),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(26)),
                  child: Column(children: [
                    const Text('제시어',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(currentWord,
                        style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 24),
                CameraRecorderWidget(
                  roomCode: widget.roomCode,
                  currentWord: currentWord,
                  status: status,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}