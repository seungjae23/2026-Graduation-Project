import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SignPlayApp());
}

class SignPlayApp extends StatelessWidget {
  const SignPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Play',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 로고 + 앱 이름
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.sign_language,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Sign Play',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E3A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 42),

              const Text(
                '실시간 수어 제스처 게임',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E3A),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                '제시어를 보고 수어를 표현하고,\n상대방은 영상을 보며 정답을 맞혀요.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF77778A),
                ),
              ),

              const SizedBox(height: 34),

              // 소개 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: const [
                    _FeatureItem(
                      icon: Icons.videocam,
                      title: '실시간 영상',
                      description: '1P의 수어 동작을 2P에게 실시간 전달',
                    ),
                    SizedBox(height: 16),
                    _FeatureItem(
                      icon: Icons.sports_esports,
                      title: '역할 기반 게임',
                      description: '1P는 표현하고 2P는 정답을 입력',
                    ),
                    SizedBox(height: 16),
                    _FeatureItem(
                      icon: Icons.psychology,
                      title: 'AI 동작 가이드',
                      description: '수어 동작 인식 결과를 게임에 활용',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              _MainButton(
                text: '방 만들기',
                icon: Icons.add,
                backgroundColor: const Color(0xFF6C63FF),
                textColor: Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateRoomScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              _MainButton(
                text: '방 참가하기',
                icon: Icons.login,
                backgroundColor: Colors.white,
                textColor: Color(0xFF2E2E3A),
                onTap: () {},
              ),

              const SizedBox(height: 14),

              _MainButton(
                text: '카메라 테스트',
                icon: Icons.camera_alt,
                backgroundColor: Colors.white,
                textColor: Color(0xFF2E2E3A),
                onTap: () {},
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F0FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E3A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Color(0xFF77778A)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _MainButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 방 만들기
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '방 만들기',
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
              const Text(
                '새 게임 방을\n만들어볼까요?',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E3A),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                '친구가 참가할 수 있는 방을 만들고\n수어 제스처 게임을 시작해보세요.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF77778A),
                ),
              ),

              const SizedBox(height: 32),

              _InputBox(
                label: '방 이름',
                hintText: '예: 수어 배틀 하실분?',
                icon: Icons.meeting_room,
                controller: roomNameController,
              ),

              const SizedBox(height: 18),

              _InputBox(
                label: '닉네임',
                hintText: '예: Player A',
                icon: Icons.person,
                controller: nicknameController,
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '게임 진행 방식',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E3A),
                      ),
                    ),

                    SizedBox(height: 16),

                    _RuleItem(number: '1', text: 'A가 먼저 5라운드 동안 수어를 표현해요.'),

                    SizedBox(height: 12),

                    _RuleItem(number: '2', text: 'B는 A의 영상을 보고 정답을 입력해요.'),

                    SizedBox(height: 12),

                    _RuleItem(number: '3', text: '5라운드가 끝나면 B가 표현자로 바뀌어요.'),

                    SizedBox(height: 12),

                    _RuleItem(number: '4', text: '정답을 많이 맞힌 플레이어가 승리해요.'),
                  ],
                ),
              ),

              const Spacer(),

              _PrimaryButton(
                text: '방 생성하기',
                icon: Icons.add,
                onTap: () {
                  final nickname = nicknameController.text.trim();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WaitingRoomScreen(
                        hostNickname: nickname.isEmpty ? 'Player A' : nickname,
                      ),
                    ),
                  );
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

class _InputBox extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;

  const _InputBox({
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E3A),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String number;
  final String text;

  const _RuleItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF77778A),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF6C63FF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//대기방

class WaitingRoomScreen extends StatefulWidget {
  final String hostNickname;

  const WaitingRoomScreen({super.key, required this.hostNickname});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  late final String roomCode;

  @override
  void initState() {
    super.initState();
    roomCode = generateRoomCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '대기방',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E3A),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '친구가 참가하면\n게임을 시작할 수 있어요',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  '아래 방 코드를 친구에게 공유해주세요.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF77778A)),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '방 코드',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        roomCode,
                        style: const TextStyle(
                          fontSize: 36,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              '코드 복사',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  '참가 플레이어',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 14),

                _PlayerCard(
                  playerName: widget.hostNickname,
                  role: '방장',
                  status: '준비 완료',
                  icon: Icons.person,
                  isReady: true,
                ),

                const SizedBox(height: 14),

                const _PlayerCard(
                  playerName: 'Player B',
                  role: '참가자',
                  status: '참가 대기 중',
                  icon: Icons.person_outline,
                  isReady: false,
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이번 게임 규칙',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'A가 먼저 5라운드 동안 수어를 표현하고,\nB가 정답을 맞혀 점수를 얻습니다.\n이후 B가 5라운드 동안 표현자로 바뀝니다.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF77778A),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _PrimaryButton(
                  text: '게임 시작하기',
                  icon: Icons.play_arrow,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TurnIntroScreen(attackerName: widget.hostNickname),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String playerName;
  final String role;
  final String status;
  final IconData icon;
  final bool isReady;

  const _PlayerCard({
    required this.playerName,
    required this.role,
    required this.status,
    required this.icon,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 28),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF77778A),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isReady
                  ? const Color(0xFFE8FFF1)
                  : const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isReady
                    ? const Color(0xFF1CA56F)
                    : const Color(0xFFE09A2B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 대기실 생성시 코드 랜덤 생성

String generateRoomCode() {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  const allChars = letters + numbers;

  final random = Random();

  final codeChars = <String>[
    letters[random.nextInt(letters.length)],
    numbers[random.nextInt(numbers.length)],
  ];

  for (int i = 0; i < 4; i++) {
    codeChars.add(allChars[random.nextInt(allChars.length)]);
  }

  codeChars.shuffle(random);

  return codeChars.join();
}

// 게임 시작하기

class TurnIntroScreen extends StatelessWidget {
  final String attackerName;

  const TurnIntroScreen({super.key, required this.attackerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '턴 시작',
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
                    Icons.sign_language,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Center(
                child: Text(
                  '$attackerName 공격 턴 시작!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  '이번 턴에서는 $attackerName님이 수어를 표현하고\nPlayer B가 정답을 맞힙니다.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                      icon: Icons.sign_language,
                      title: '표현자',
                      value: attackerName,
                    ),
                    SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.edit,
                      title: '정답자',
                      value: 'Player B',
                    ),
                    SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.flag,
                      title: '진행 라운드',
                      value: '총 5라운드',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              _PrimaryButton(
                text: '시작하기',
                icon: Icons.play_arrow,
                onTap: () {
                  // 다음 단계에서 실제 게임 화면으로 이동
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
  final IconData icon;
  final String title;
  final String value;

  const _TurnInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F0FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, color: Color(0xFF77778A)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E3A),
          ),
        ),
      ],
    );
  }
}
