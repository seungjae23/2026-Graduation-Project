import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'turn_intro_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String hostNickname;
  final String roomCode;
  final bool isHost;

  const WaitingRoomScreen({
    super.key,
    required this.hostNickname,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        title: const Text('대기방', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2E2E3A),
      ),
      // 💡 파이어베이스 방 데이터를 실시간으로 모니터링하여 참가자가 들어오면 즉시 화면을 갱신합니다.
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final roomData = snapshot.data!.data() as Map<String, dynamic>;
          final String roomName = roomData['roomName'] ?? '게임방';
          final String hostName = roomData['hostNickname'] ?? widget.hostNickname;
          final String playerB = roomData['playerB'] ?? '';
          final String status = roomData['status'] ?? 'waiting';

          // 💡 방장이 시작 버튼을 눌러 status가 'playing'이 되면 양쪽 폰 모두 자동으로 턴 인트로 화면으로 자동 이동!
          if (status == 'playing') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TurnIntroScreen(
                    roomCode: widget.roomCode,
                    myNickname: widget.isHost ? hostName : playerB,
                    attackerName: hostName, // 1라운드는 방장(1P)의 공격으로 강제 세팅
                  ),
                ),
              );
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text('$roomName\n방에 연결되었습니다', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A), height: 1.3)),
                    const SizedBox(height: 12),
                    const Text('아래 방 코드를 친구에게 공유해주세요.', style: TextStyle(fontSize: 15, color: Color(0xFF77778A))),
                    const SizedBox(height: 30),

                    // 방 코드 표시 영역 카드
                    Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(color: const Color(0xFF7D77FF), borderRadius: BorderRadius.circular(32)),
                      child: Column(children: [
                        const Text('방 코드', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 12),
                        Text(widget.roomCode, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.roomCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('방 코드가 복사되었습니다!'), backgroundColor: Color(0xFF6C63FF)),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('코드 복사'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2), 
                            foregroundColor: Colors.white, 
                            elevation: 0, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 40),
                    const Text('참가 플레이어', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
                    const SizedBox(height: 16),
                    
                    _PlayerCard(name: hostName, role: '방장', status: '준비 완료', isReady: true),
                    const SizedBox(height: 12),
                    _PlayerCard(
                      name: playerB.isEmpty ? '참가자 대기 중...' : playerB, 
                      role: '참가자', 
                      status: playerB.isEmpty ? '대기 중' : '준비 완료', 
                      isReady: playerB.isNotEmpty
                    ),

                    const SizedBox(height: 40),
                    
                    // 하단 제어 버튼
                    SizedBox(
                      width: double.infinity, height: 60,
                      child: ElevatedButton(
                        onPressed: (widget.isHost && playerB.isNotEmpty) ? () async {
                          // 방장이 시작 버튼을 누르면 파이어베이스 status 업데이트 -> playing 상태 유도
                          await FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode).update({
                            'status': 'playing'
                          });
                        } : null, // 참가자이거나, 아직 친구가 방에 안 들어왔으면 버튼 비활성화
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (widget.isHost && playerB.isNotEmpty) ? const Color(0xFF6C63FF) : Colors.grey[400], 
                          foregroundColor: Colors.white, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        child: Text(
                          widget.isHost 
                              ? (playerB.isEmpty ? '참가자를 기다리는 중...' : '게임 시작하기')
                              : '방장이 게임을 시작하기를 기다리는 중...', 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String name; final String role; final String status; final bool isReady;
  const _PlayerCard({required this.name, required this.role, required this.status, required this.isReady});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        CircleAvatar(backgroundColor: const Color(0xFFF1F0FF), child: Icon(Icons.person, color: isReady ? const Color(0xFF6C63FF) : Colors.grey)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(role, style: const TextStyle(fontSize: 13, color: Colors.grey))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isReady ? const Color(0xFFEFFFF4) : const Color(0xFFFFF6E9), borderRadius: BorderRadius.circular(10)), child: Text(status, style: TextStyle(color: isReady ? const Color(0xFF4CAF50) : const Color(0xFFFF9800), fontSize: 12, fontWeight: FontWeight.bold))),
      ]),
    );
  }
}