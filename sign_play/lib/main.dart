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
                text: '표현자 화면 시작',
                icon: Icons.sign_language,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SignerGameScreen(playerName: attackerName),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              _PrimaryButton(
                text: '정답자 화면 테스트',
                icon: Icons.edit,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuesserGameScreen(
                        guesserName: 'Player B',
                        signerName: attackerName,
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

// 게임중

class GuesserGameScreen extends StatefulWidget {
  final String guesserName;
  final String signerName;

  const GuesserGameScreen({
    super.key,
    required this.guesserName,
    required this.signerName,
  });

  @override
  State<GuesserGameScreen> createState() => _GuesserGameScreenState();
}

class _GuesserGameScreenState extends State<GuesserGameScreen> {
  final TextEditingController answerController = TextEditingController();

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const currentRound = 1;
    const totalRound = 5;
    const timeLeft = 30;
    const score = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '정답자 화면',
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
                Row(
                  children: [
                    Expanded(
                      child: _StatusBox(
                        title: '라운드',
                        value: '$currentRound / $totalRound',
                        icon: Icons.flag,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusBox(
                        title: '남은 시간',
                        value: '$timeLeft초',
                        icon: Icons.timer,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _StatusBox(title: '현재 점수', value: '$score점', icon: Icons.stars),

                const SizedBox(height: 24),

                Text(
                  '${widget.guesserName}님, 정답을 맞혀보세요',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${widget.signerName}님의 수어 동작을 보고 정답을 입력해주세요.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF77778A),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E3A),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.live_tv,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '상대방 실시간 영상 영역',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '나중에 WebRTC 영상 뷰어가 들어갈 자리',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  '정답 입력',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    hintText: '정답을 입력하세요',
                    prefixIcon: const Icon(
                      Icons.edit,
                      color: Color(0xFF6C63FF),
                    ),
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

                const SizedBox(height: 22),

                _PrimaryButton(
                  text: '정답 제출',
                  icon: Icons.send,
                  onTap: () {
                    final answer = answerController.text.trim();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          answer.isEmpty ? '정답을 입력해주세요.' : '입력한 정답: $answer',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

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
                        '정답자 안내',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '상대방의 수어 동작을 보고 제한 시간 안에 정답을 입력하세요.\n정답을 맞히면 점수가 올라갑니다.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF77778A),
                        ),
                      ),
                    ],
                  ),
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

class _StatusBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatusBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF77778A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 표현자 화면

class SignerGameScreen extends StatelessWidget {
  final String playerName;

  const SignerGameScreen({super.key, required this.playerName});

  @override
  Widget build(BuildContext context) {
    const currentRound = 1;
    const totalRound = 5;
    const timeLeft = 30;
    final currentWord = generateRandomWord();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '표현자 화면',
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
                Row(
                  children: [
                    Expanded(
                      child: _StatusBox(
                        title: '라운드',
                        value: '$currentRound / $totalRound',
                        icon: Icons.flag,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusBox(
                        title: '남은 시간',
                        value: '$timeLeft초',
                        icon: Icons.timer,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  '$playerName님 차례예요',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  '제시어를 보고 수어 동작을 표현해주세요.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF77778A)),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
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
                        '제시어',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentWord,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E3A),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '카메라 화면 영역',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '나중에 MediaPipe 카메라 위젯이 들어갈 자리',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.back_hand, color: Color(0xFF6C63FF), size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '손 인식 상태',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E3A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'MediaPipe 연결 전입니다',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF77778A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

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
                        'AI 동작 가이드',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 14),
                      _GuideText(text: '손이 화면 중앙에 오도록 해주세요.'),
                      SizedBox(height: 8),
                      _GuideText(text: '밝은 곳에서 촬영해주세요.'),
                      SizedBox(height: 8),
                      _GuideText(text: '제시어에 맞는 수어를 천천히 표현해주세요.'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _PrimaryButton(
                  text: '동작 완료',
                  icon: Icons.check,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('동작 완료 버튼이 눌렸습니다.')),
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

class _GuideText extends StatelessWidget {
  final String text;

  const _GuideText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF6C63FF), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF77778A)),
          ),
        ),
      ],
    );
  }
}

String generateRandomWord() {
  const words = [
    // 인사
    '안녕하세요',
    '반가워요',
    '고마워요',
    '감사합니다',
    '미안해요',
    '괜찮아요',
    '잘가요',
    '또 만나요',
    '잘 지내요',
    '처음 봐요',
    '오랜만이야',
    '환영해요',

    // 감정
    '좋아요',
    '싫어요',
    '기뻐요',
    '슬퍼요',
    '화나요',
    '무서워요',
    '놀랐어요',
    '행복해요',
    '심심해요',
    '피곤해요',
    '재밌어요',
    '부끄러워',
    '걱정돼요',
    '신나요',
    '답답해요',

    // 일상 행동
    '밥 먹자',
    '물 주세요',
    '도와줘요',
    '기다려요',
    '앉으세요',
    '일어나요',
    '천천히',
    '빨리 와요',
    '조심해요',
    '쉬어요',
    '잠깐만요',
    '따라와요',
    '양치해요',
    '잠자요',
    '공부해요',

    // 장소
    '학교',
    '집',
    '병원',
    '약국',
    '화장실',
    '식당',
    '카페',
    '편의점',
    '마트',
    '도서관',
    '교실',
    '회사',
    '공원',
    '버스정류장',
    '지하철',
    '영화관',
    '은행',
    '우체국',
    '놀이터',
    '체육관',

    // 사람
    '친구',
    '가족',
    '엄마',
    '아빠',
    '언니',
    '오빠',
    '누나',
    '형',
    '동생',
    '선생님',
    '학생',
    '의사',
    '경찰',
    '손님',
    '직원',
    '아이',
    '어른',
    '할머니',
    '할아버지',

    // 음식
    '밥',
    '물',
    '우유',
    '빵',
    '라면',
    '김밥',
    '떡볶이',
    '치킨',
    '피자',
    '커피',
    '주스',
    '과자',
    '사과',
    '바나나',
    '딸기',
    '고기',
    '생선',
    '계란',
    '국수',
    '아이스크림',

    // 물건
    '가방',
    '책',
    '연필',
    '지우개',
    '핸드폰',
    '컴퓨터',
    '마우스',
    '키보드',
    '의자',
    '책상',
    '시계',
    '안경',
    '우산',
    '신발',
    '옷',
    '모자',
    '컵',
    '접시',
    '휴지',
    '열쇠',

    // 상태
    '아파요',
    '배고파요',
    '목말라요',
    '추워요',
    '더워요',
    '졸려요',
    '괜찮아요',
    '힘들어요',
    '쉬고싶어',
    '배불러요',
    '바빠요',
    '한가해요',
    '늦었어요',
    '준비됐어',
    '몰라요',
    '알겠어요',

    // 질문
    '뭐예요?',
    '어디예요?',
    '왜요?',
    '언제예요?',
    '누구예요?',
    '괜찮아요?',
    '도와줄래?',
    '먹을래요?',
    '갈까요?',
    '할까요?',
    '알겠어요?',
    '몇 시예요?',
    '이름 뭐야?',
    '어디 가요?',

    // 숫자/시간
    '하나',
    '둘',
    '셋',
    '넷',
    '다섯',
    '여섯',
    '일곱',
    '여덟',
    '아홉',
    '열',
    '오늘',
    '내일',
    '어제',
    '아침',
    '점심',
    '저녁',
    '밤',
    '지금',
    '나중에',
    '이번 주',

    // 자연/날씨
    '비 와요',
    '눈 와요',
    '맑아요',
    '흐려요',
    '바람 불어',
    '날씨 좋아',
    '하늘',
    '구름',
    '바다',
    '산',
    '나무',
    '꽃',
    '강아지',
    '고양이',
    '새',
    '물고기',

    // 게임용 짧은 문장
    '정답이에요',
    '틀렸어요',
    '다시 해요',
    '시작해요',
    '끝났어요',
    '이겼어요',
    '졌어요',
    '점수 얻음',
    '내 차례야',
    '네 차례야',
    '준비 완료',
    '시간 끝',
    '다음 문제',
    '잘했어요',
    '최고예요',
  ];

  final random = Random();
  return words[random.nextInt(words.length)];
}
