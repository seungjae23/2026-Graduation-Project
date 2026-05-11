import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'turn_intro_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String hostNickname;
  final String roomCode = "9ZV1CH"; // 이미지와 동일한 코드

  const WaitingRoomScreen({super.key, required this.hostNickname});

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
      // 💡 SafeArea로 감싸서 기기 하단바 간섭을 방지합니다.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '친구가 참가하면\n게임을 시작할 수 있어요',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A), height: 1.3),
                ),
                const SizedBox(height: 12),
                const Text(
                  '아래 방 코드를 친구에게 공유해주세요.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF77778A)),
                ),
                const SizedBox(height: 30),

                // 💜 방 코드 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7D77FF),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      const Text('방 코드', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 12),
                      Text(
                        widget.roomCode,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4),
                      ),
                      const SizedBox(height: 24),
                      // 코드 복사 버튼
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Text('참가 플레이어', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
                const SizedBox(height: 16),
                
                _PlayerCard(name: widget.hostNickname, role: '방장', status: '준비 완료', isReady: true),
                const SizedBox(height: 12),
                const _PlayerCard(name: 'Player B', role: '참가자', status: '참가 대기 중', isReady: false),

                const SizedBox(height: 40),
                
                // 💡 복구된 [이번 게임 규칙] 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이번 게임 규칙', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
                      SizedBox(height: 16),
                      Text(
                        'A가 먼저 5라운드 동안 수어를 표현하고,\nB가 정답을 맞혀 점수를 얻습니다.\n이후 B가 5라운드 동안 표현자로 바뀝니다.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF77778A), height: 1.6),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // 💡 게임 시작하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TurnIntroScreen(attackerName: widget.hostNickname),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('게임 시작하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                // 💡 하단바에 가리지 않도록 추가 여백을 줍니다.
                const SizedBox(height: 40), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 플레이어 카드 위젯 (디자인 고정)
class _PlayerCard extends StatelessWidget {
  final String name; final String role; final String status; final bool isReady;
  const _PlayerCard({required this.name, required this.role, required this.status, required this.isReady});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF1F0FF),
            child: Icon(Icons.person, color: isReady ? const Color(0xFF6C63FF) : Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(role, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isReady ? const Color(0xFFEFFFF4) : const Color(0xFFFFF6E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isReady ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                fontSize: 12, fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}