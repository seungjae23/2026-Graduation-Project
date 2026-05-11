import 'package:flutter/material.dart';

class TurnIntroScreen extends StatefulWidget {
  final String attackerName;

  const TurnIntroScreen({super.key, required this.attackerName});

  @override
  State<TurnIntroScreen> createState() => _TurnIntroScreenState();
}

class _TurnIntroScreenState extends State<TurnIntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        title: const Text('턴 시작', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2E2E3A),
      ),
      // 💡 SafeArea로 전체를 감싸 기기 하단바 간섭을 1차로 방지합니다.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 중앙 아이콘 (디자인 유지)
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Icon(Icons.sign_language, color: Colors.white, size: 50),
                ),
              ),
              const SizedBox(height: 40),
              // 메인 텍스트 (디자인 유지)
              Text(
                '${widget.attackerName} 공격 턴 시작!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)),
              ),
              const SizedBox(height: 16),
              Text(
                '이번 턴에서는 ${widget.attackerName}님이 수어를 표현하고\n상대방이 정답을 맞힙니다.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF77778A), height: 1.5),
              ),
              const SizedBox(height: 40),
              // 정보 카드 (디자인 유지)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(icon: Icons.sign_language, label: '표현자', value: widget.attackerName, color: const Color(0xFF6C63FF)),
                    const Divider(height: 32),
                    const _InfoRow(icon: Icons.edit, label: '정답자', value: 'Player B', color: Colors.blue),
                    const Divider(height: 32),
                    const _InfoRow(icon: Icons.flag, label: '진행 라운드', value: '총 5라운드', color: Colors.indigo),
                  ],
                ),
              ),
              
              const Spacer(), // 버튼을 아래로 밀어냅니다.

              // 💡 하단 버튼 영역 수정
              Padding(
                padding: const EdgeInsets.only(bottom: 20), // 하단바 위 여백 확보
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이제 게임 화면으로 연결될 차례입니다!')),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('시작하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              // 💡 시스템 내비게이션 바를 위한 안전 장치 여백 추가
              const SizedBox(height: 10), 
            ],
          ),
        ),
      ),
    );
  }
}

// 정보 행 위젯 (디자인 유지)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF77778A))),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
      ],
    );
  }
}