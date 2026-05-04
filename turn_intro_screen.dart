import 'package:flutter/material.dart';
import '../main.dart'; // PrimaryButton 가져오기

class TurnIntroScreen extends StatelessWidget {
  final String attackerName;
  const TurnIntroScreen({super.key, required this.attackerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(backgroundColor: const Color(0xFFF7F6FF), elevation: 0, centerTitle: true, title: const Text('턴 시작', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(child: Container(width: 92, height: 92, decoration: BoxDecoration(color: const Color(0xFF6C63FF), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 18, offset: const Offset(0, 8))]), child: const Icon(Icons.sign_language, color: Colors.white, size: 48))),
              const SizedBox(height: 36),
              Center(child: Text('$attackerName 공격 턴 시작!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A)))),
              const SizedBox(height: 12),
              Center(child: Text('이번 턴에서는 $attackerName님이 수어를 표현하고\nPlayer B가 정답을 맞힙니다.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF77778A)))),
              const SizedBox(height: 36),
              
              Container(
                width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
                child: Column(
                  children: [
                    _TurnInfoItem(icon: Icons.sign_language, title: '표현자', value: attackerName), const SizedBox(height: 18),
                    const _TurnInfoItem(icon: Icons.edit, title: '정답자', value: 'Player B'), const SizedBox(height: 18),
                    const _TurnInfoItem(icon: Icons.flag, title: '진행 라운드', value: '총 5라운드'),
                  ],
                ),
              ),
              const Spacer(),
              
              PrimaryButton(
                text: '시작하기', icon: Icons.play_arrow,
                onTap: () {
                  // TODO: 실제 게임 화면으로 이동
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

class _TurnInfoItem extends StatelessWidget {
  final IconData icon; final String title; final String value;
  const _TurnInfoItem({required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFF1F0FF), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: const Color(0xFF6C63FF), size: 26)),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF77778A)))),
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
      ],
    );
  }
}