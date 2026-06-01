import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart'; // 💡 비디오 재생 패키지 임포트
import 'game_screen.dart';

class TurnIntroScreen extends StatefulWidget {
  final String roomCode;       
  final String myNickname;     
  final String attackerName;   

  const TurnIntroScreen({
    super.key, 
    required this.roomCode, 
    required this.myNickname,
    required this.attackerName,
  });

  @override
  State<TurnIntroScreen> createState() => _TurnIntroScreenState();
}

class _TurnIntroScreenState extends State<TurnIntroScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyTurn = widget.myNickname == widget.attackerName;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        title: const Text('게임 진행', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2E2E3A),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final roomData = snapshot.data!.data() as Map<String, dynamic>;
          final String currentStatus = roomData['status'] ?? 'waiting';
          final String correctAnswer = roomData['correctAnswer'] ?? '';
          final String roundResult = roomData['roundResult'] ?? 'correct'; // 정답 여부 (correct / wrong)
          final String videoUrl = roomData['videoUrl'] ?? '';

          // 💡 [실시간 연동] 맞추든 틀리든 status가 완료되면 1P, 2P 동시에 결과 팝업창 가동!
          if (currentStatus == 'round_completed') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showRoundCompleteDialog(context, roundResult, correctAnswer);
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: const Color(0xFF6C63FF), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.sports_esports, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text('${widget.attackerName} 님의 공격 턴', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
                  const SizedBox(height: 10),

                  Text(
                    currentStatus == 'waiting_for_answer'
                        ? (isMyTurn ? '상대방이 정답을 입력하고 있습니다...' : '영상이 도착했습니다! 아래에 정답을 입력하세요.')
                        : (isMyTurn ? '녹화 시작 버튼을 눌러 수어를 표현해 주세요!' : '1P가 수어를 녹화하고 있습니다. 잠시만 기다려주세요...'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF77778A)),
                  ),
                  const SizedBox(height: 30),

                  // 🔥 [영상 출력 + 정답 패널] 2P(수비자)에게 영상이 오면 조건 활성화
                  if (!isMyTurn && currentStatus == 'waiting_for_answer') ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(24), 
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)]
                      ),
                      child: Column(
                        children: [
                          // 🎬 2P 화면에 가짜 글자 대신 진짜 동영상 플레이어 장착!
                          if (videoUrl.isNotEmpty)
                            _VideoPlayerWidget(videoUrl: videoUrl)
                          else
                            const Text('영상을 불러오는 중 오류가 발생했습니다.', style: TextStyle(color: Colors.grey)),
                          
                          const SizedBox(height: 24),
                          TextField(
                            controller: _answerController,
                            decoration: InputDecoration(
                              hintText: '정답을 입력하세요',
                              filled: true, fillColor: const Color(0xFFF7F6FF),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity, height: 55,
                            child: ElevatedButton(
                              onPressed: () async {
                                final userAnswer = _answerController.text.trim();
                                if (userAnswer == correctAnswer) {
                                  // 🎯 맞춘 경우: 성공 상태 기록
                                  await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).update({
                                    'status': 'round_completed',
                                    'roundResult': 'correct'
                                  });
                                } else {
                                  // 🎯 틀린 경우 정호 님의 요청사항: 틀려도 얄짤없이(?) 결과창으로 양쪽 다 강제 전송!
                                  await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).update({
                                    'status': 'round_completed',
                                    'roundResult': 'wrong'
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              child: const Text('정답 제출하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 1P가 서버 전송 후 무기한 대기 탈 때 도는 버퍼 로딩바
                  if (isMyTurn && currentStatus == 'waiting_for_answer') ...[
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    const SizedBox(height: 16),
                    const Text('상대방이 정답을 심사 숙고 중입니다...', style: TextStyle(color: Color(0xFF77778A))),
                  ],

                  const SizedBox(height: 30),
                  
                  // 녹화 전송 시작 버튼 (라운드 시작 전 1P 전용 마스터키)
                  if (currentStatus != 'waiting_for_answer')
                    SizedBox(
                      width: double.infinity, height: 60,
                      child: ElevatedButton(
                        onPressed: isMyTurn ? () {
                          FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).update({'status': 'recording'});
                          Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen(roomCode: widget.roomCode, attackerName: widget.attackerName)));
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMyTurn ? const Color(0xFF6C63FF) : Colors.grey[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(isMyTurn ? '녹화 시작하기' : '1P 녹화 대기 중...', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 💡 맞췄을 때와 틀렸을 때 분기처리된 커스텀 다이얼로그 결과창
  void _showRoundCompleteDialog(BuildContext context, String roundResult, String correctAnswer) {
    final bool isCorrect = roundResult == 'correct';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isCorrect ? '🎉 라운드 종료 (정답!)' : '❌ 라운드 종료 (오답)',
          style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.redAccent),
        ),
        content: Text(
          isCorrect 
              ? '2P가 정답을 완벽하게 맞혔습니다!\n축하합니다. 다음 단계로 넘어갑니다.'
              : '아쉽게도 틀렸습니다!\n2P가 오답을 제출하여 정답 맞추기에 실패했습니다.\n(정답은 [$correctAnswer] 이었습니다.)',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 결과창 닫기
              Navigator.pop(context); // 1P, 2P 둘 다 메인 대기방으로 철수!
            },
            child: const Text('확인', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }
}

// 🎬 [동영상 컴포넌트 위젯] 서버 주소를 받아서 내부 플레이어를 세팅합니다.
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // 파이어베이스에 담긴 가짜 주소(mock)일 경우 앱이 다운되는 현상을 막기 위한 주소 판별 처리
    String targetUrl = widget.videoUrl.contains('mock-firebase-storage')
        ? 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4' // 💡 가짜 주소일 땐 샘플 영상 자동 대체 재생!
        : widget.videoUrl;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(targetUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _videoController.setLooping(true); // 반복 재생
        _videoController.play();           // 화면 진입 시 즉시 자동 재생
      }).catchError((error) {
        debugPrint("비디오 초기화 실패 로그: $error");
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
      );
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: VideoPlayer(_videoController),
          ),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _videoController.value.isPlaying ? _videoController.pause() : _videoController.play();
            });
          },
          icon: Icon(_videoController.value.isPlaying ? Icons.pause : Icons.play_arrow, size: 18, color: const Color(0xFF6C63FF)),
          label: Text(_videoController.value.isPlaying ? '일시정지' : '재생하기', style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 13)),
        )
      ],
    );
  }
}