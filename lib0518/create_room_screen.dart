import 'package:flutter/material.dart';
import 'dart:math'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'main.dart'; 
import 'waiting_room_screen.dart'; 

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  @override
  void dispose() {
    roomNameController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(title: const Text('방 만들기'), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('새 게임 방을\n만들어볼까요?', style: TextStyle(fontSize: 30, height: 1.25, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
                const SizedBox(height: 10),
                const Text('친구가 참가할 수 있는 방을 만들고\n수어 제스처 게임을 시작해보세요.', style: TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF77778A))),
                const SizedBox(height: 32),
                
                _InputBox(label: '방 이름', hintText: '예: 수어 배틀 하실분?', icon: Icons.meeting_room, controller: roomNameController),
                const SizedBox(height: 18),
                _InputBox(label: '닉네임', hintText: '예: Player A', icon: Icons.person, controller: nicknameController),
                const SizedBox(height: 28),
                
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(22),
                  // 💡 1번 경고 수정: withOpacity -> withValues(alpha: ...)
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6))]),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('게임 진행 방식', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
                      SizedBox(height: 16),
                      _RuleItem(number: '1', text: 'A가 먼저 5라운드 동안 수어를 표현해요.'),
                      SizedBox(height: 12),
                      _RuleItem(number: '2', text: 'B는 A의 영상을 보고 정답을 입력해요.'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                PrimaryButton(
                  text: '방 생성하기',
                  icon: Icons.add,
                  onTap: () async {
                    final roomName = roomNameController.text.trim();
                    final nickname = nicknameController.text.trim();
                    
                    if (roomName.isEmpty || nickname.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('방 이름과 닉네임을 모두 입력해주세요!')),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final generatedCode = _generateRoomCode();

                      await FirebaseFirestore.instance.collection('rooms').doc(generatedCode).set({
                        'roomName': roomName,
                        'hostNickname': nickname,
                        'playerB': '', 
                        'status': 'waiting', 
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      // 💡 2번 경고 수정: !mounted를 !context.mounted로 교체
                      if (!context.mounted) return;
                      Navigator.pop(context); // 로딩창 닫기

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingRoomScreen(
                            hostNickname: nickname,
                            roomCode: generatedCode, 
                            isHost: true, 
                          ),
                        ),
                      );
                    } catch (e) {
                      // 💡 2번 경고 수정: !mounted를 !context.mounted로 교체
                      if (!context.mounted) return;
                      Navigator.pop(context); // 로딩창 닫기
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('방 생성에 실패했습니다: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String label; final String hintText; final IconData icon; final TextEditingController controller;
  const _InputBox({required this.label, required this.hintText, required this.icon, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hintText, prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
      ),
    ]);
  }
}

class _RuleItem extends StatelessWidget {
  final String number; final String text;
  const _RuleItem({required this.number, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 26, height: 26, decoration: BoxDecoration(color: const Color(0xFF6C63FF), borderRadius: BorderRadius.circular(9)), child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)))),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF77778A)))),
    ]);
  }
}