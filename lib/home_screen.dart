import 'package:flutter/material.dart';
import 'create_room_screen.dart'; // 💡 경로 수정 (../ 제거)
import 'join_room_screen.dart';   // 💡 경로 수정 (../ 제거)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF6C63FF);
    const Color textHeadingColor = Color(0xFF2E2E3A);
    const Color textBodyColor = Color(0xFF77778A);
    const Color bgColor = Color(0xFFF7F6FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderSection(),
              const SizedBox(height: 32),
              const Text(
                '실시간 수어\n제스처 게임',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textHeadingColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '제시어를 보고 수어를 표현하고,\n상대방은 영상을 보며 정답을 맞혀요.',
                style: TextStyle(fontSize: 16, color: textBodyColor, height: 1.5),
              ),
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Column(
                  children: [
                    _FeatureItem(icon: Icons.videocam_rounded, title: '실시간 영상', description: '1P의 수어 동작을 2P에게 실시간 전달'),
                    SizedBox(height: 16),
                    _FeatureItem(icon: Icons.sports_esports_rounded, title: '역할 기반 게임', description: '1P는 표현하고 2P는 정답을 입력'),
                    SizedBox(height: 16),
                    _FeatureItem(icon: Icons.psychology_rounded, title: 'AI 동작 가이드', description: '수어 동작 인식 결과를 게임에 활용'),
                  ],
                ),
              ),
              
              const SizedBox(height: 40), 
              
              _MainButton(
                text: '방 만들기',
                icon: Icons.add,
                backgroundColor: primaryPurple,
                textColor: Colors.white,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRoomScreen())),
              ),
              const SizedBox(height: 14),
              _MainButton(
                text: '방 참가하기',
                icon: Icons.login_rounded,
                backgroundColor: Colors.white,
                textColor: textHeadingColor,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JoinRoomScreen())), 
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 54, height: 54,
        decoration: BoxDecoration(color: const Color(0xFF6C63FF), borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.sign_language, color: Colors.white, size: 32),
      ),
      const SizedBox(width: 14),
      const Text('Sign Play', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
    ]);
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon; final String title; final String description;
  const _FeatureItem({required this.icon, required this.title, required this.description});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFF1F0FF), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF6C63FF), size: 24)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))), Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF77778A)))]))
    ]);
  }
}

class _MainButton extends StatelessWidget {
  final String text; final IconData icon; final Color backgroundColor; final Color textColor; final VoidCallback onTap;
  const _MainButton({required this.text, required this.icon, required this.backgroundColor, required this.textColor, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor, borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20), onTap: onTap,
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: backgroundColor == Colors.white ? BoxDecoration(border: Border.all(color: const Color(0xFFE2E2E2)), borderRadius: BorderRadius.circular(20)) : null,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: textColor, size: 22), const SizedBox(width: 10), Text(text, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor))]),
        ),
      ),
    );
  }
}