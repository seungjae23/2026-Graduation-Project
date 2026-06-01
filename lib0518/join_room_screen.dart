import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';                 // 💡 경로 수정 (../ 제거)
import 'waiting_room_screen.dart';  // 💡 경로 수정 (../ 제거)

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController roomCodeController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  @override
  void dispose() {
    roomCodeController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(title: const Text('방 참가하기'), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('친구의 방에\n입장해볼까요?', style: TextStyle(fontSize: 30, height: 1.25, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
                const SizedBox(height: 10),
                const Text('전달받은 6자리 방 코드를 입력해주세요.', style: TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF77778A))),
                const SizedBox(height: 32),
                
                _InputBox(label: '방 코드', hintText: '예: A1B2C3', icon: Icons.tag, controller: roomCodeController, isUppercase: true),
                const SizedBox(height: 18),
                _InputBox(label: '닉네임', hintText: '예: Player B', icon: Icons.person, controller: nicknameController),
                const SizedBox(height: 40),
                
                PrimaryButton(
                  text: '입장하기',
                  icon: Icons.login_rounded,
                  onTap: () async {
                    final roomCode = roomCodeController.text.trim().toUpperCase();
                    final nickname = nicknameController.text.trim();
                    
                    if (roomCode.isEmpty || nickname.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('방 코드와 닉네임을 모두 입력해주세요!')));
                      return;
                    }

                    if (roomCode.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('방 코드는 6자리입니다. 다시 확인해주세요.')));
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final docRef = FirebaseFirestore.instance.collection('rooms').doc(roomCode);
                      final docSnap = await docRef.get();

                      if (!context.mounted) return;
                      Navigator.pop(context); // 로딩창 닫기

                      if (!docSnap.exists) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('존재하지 않는 방입니다. 코드를 확인해주세요.')));
                        return;
                      }

                      final data = docSnap.data() as Map<String, dynamic>;

                      if (data['playerB'] != null && data['playerB'] != '') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미 참가자가 있는 방입니다.')));
                        return;
                      }

                      await docRef.update({
                        'playerB': nickname,
                      });

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingRoomScreen(
                            hostNickname: data['hostNickname'], 
                            roomCode: roomCode, 
                            isHost: false, 
                          ),
                        ),
                      );

                    } catch (e) {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('입장 실패: $e')));
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
  final String label; final String hintText; final IconData icon; final TextEditingController controller; final bool isUppercase;
  const _InputBox({required this.label, required this.hintText, required this.icon, required this.controller, this.isUppercase = false});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2E3A))),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.none, 
        decoration: InputDecoration(hintText: hintText, prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
      ),
    ]);
  }
}