import 'dart:math';
import 'package:flutter/material.dart';
import 'screens/webrtc_test_screen.dart';

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinRoomScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              _MainButton(
                text: '카메라 테스트',
                icon: Icons.camera_alt,
                backgroundColor: Colors.white,
                textColor: Color(0xFF2E2E3A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraTestScreen(),
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

// 방 참가하기
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

  void _joinRoom() {
    final roomCode = roomCodeController.text.trim().replaceAll(' ', '').toUpperCase();
    final nickname = nicknameController.text.trim();

    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 코드를 입력해주세요.')),
      );
      return;
    }

    if (roomCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6자리 방 코드를 입력해주세요.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitingRoomScreen(
          hostNickname: 'Player A',
          roomCode: roomCode,
          guestNickname: nickname.isEmpty ? 'Player B' : nickname,
          isHost: false,
        ),
      ),
    );
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
          '방 참가하기',
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
                  '친구의 방에\n참가해볼까요?',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  '방장이 공유한 6자리 코드를 입력하고\n대기방으로 이동해보세요.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF77778A),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  '방 코드',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: roomCodeController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Color(0xFF2E2E3A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'A7K2Q9',
                    hintStyle: const TextStyle(
                      letterSpacing: 3,
                      color: Color(0xFFB7B4CC),
                    ),
                    prefixIcon: const Icon(
                      Icons.tag,
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

                const SizedBox(height: 18),

                _InputBox(
                  label: '닉네임',
                  hintText: '예: Player B',
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
                        '참가 순서',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 16),
                      _RuleItem(number: '1', text: '방장이 알려준 방 코드를 입력해요.'),
                      SizedBox(height: 12),
                      _RuleItem(number: '2', text: '게임에서 사용할 닉네임을 정해요.'),
                      SizedBox(height: 12),
                      _RuleItem(number: '3', text: '대기방에서 방장이 게임을 시작할 때까지 기다려요.'),
                    ],
                  ),
                ),

                const SizedBox(height: 34),

                _PrimaryButton(
                  text: '방 참가하기',
                  icon: Icons.login,
                  onTap: _joinRoom,
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

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  int statusIndex = 0;

  final List<_CameraStatus> statuses = const [
    _CameraStatus(
      title: '카메라 권한 대기',
      description: '테스트를 시작하려면 카메라 권한을 허용해주세요.',
      icon: Icons.lock_outline,
      color: Color(0xFFE09A2B),
    ),
    _CameraStatus(
      title: '손 인식 중',
      description: '손이 화면 중앙에 오도록 위치를 맞춰주세요.',
      icon: Icons.back_hand,
      color: Color(0xFF6C63FF),
    ),
    _CameraStatus(
      title: '인식 준비 완료',
      description: '손 위치와 화면 밝기가 안정적입니다.',
      icon: Icons.check_circle,
      color: Color(0xFF1CA56F),
    ),
    _CameraStatus(
      title: '조명이 어두워요',
      description: '밝은 곳으로 이동하거나 손을 더 잘 보이게 해주세요.',
      icon: Icons.light_mode,
      color: Color(0xFFE25B5B),
    ),
  ];

  _CameraStatus get currentStatus => statuses[statusIndex];

  void _nextStatus() {
    setState(() {
      statusIndex = (statusIndex + 1) % statuses.length;
    });
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
          '카메라 테스트',
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
                  '수어 인식 준비를\n확인해볼까요?',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'MediaPipe 연결 전까지는 상태를 직접 바꿔보며\n카메라 테스트 UI를 확인할 수 있어요.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF77778A),
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  height: 320,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E3A),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '카메라 미리보기 영역',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '나중에 실제 카메라 위젯이 들어갈 자리',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: currentStatus.color.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                currentStatus.icon,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  currentStatus.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: currentStatus.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          currentStatus.icon,
                          color: currentStatus.color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentStatus.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E3A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentStatus.description,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
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
                        '촬영 체크리스트',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E3A),
                        ),
                      ),
                      SizedBox(height: 14),
                      _GuideText(text: '손과 얼굴이 화면 안에 들어오게 맞춰주세요.'),
                      SizedBox(height: 8),
                      _GuideText(text: '역광이 심하지 않은 밝은 장소에서 테스트해주세요.'),
                      SizedBox(height: 8),
                      _GuideText(text: '손을 너무 빠르게 움직이지 말고 천천히 표현해주세요.'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _PrimaryButton(
                  text: '테스트 상태 변경',
                  icon: Icons.sync,
                  onTap: _nextStatus,
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

class _CameraStatus {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _CameraStatus({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
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
  final bool enabled;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFF6C63FF) : const Color(0xFFC9C5FF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
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
  final String? roomCode;
  final String? guestNickname;
  final bool isHost;

  const WaitingRoomScreen({
    super.key,
    required this.hostNickname,
    this.roomCode,
    this.guestNickname,
    this.isHost = true,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  late final String roomCode;
  bool guestReady = false;

  @override
  void initState() {
    super.initState();
    roomCode = widget.roomCode ?? generateRoomCode();
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
                Text(
                  widget.isHost
                      ? '친구가 참가하면\n게임을 시작할 수 있어요'
                      : '방에 참가했어요\n게임 시작을 기다려요',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.isHost
                      ? '아래 방 코드를 친구에게 공유해주세요.'
                      : '입장한 방 코드와 참가 정보를 확인해주세요.',
                  style: const TextStyle(fontSize: 15, color: Color(0xFF77778A)),
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
                  status: '준비중',
                  icon: Icons.person,
                  isReady: false,
                ),

                const SizedBox(height: 14),

                _PlayerCard(
                  playerName: widget.guestNickname ?? 'Player B',
                  role: '참가자',
                  status: widget.guestNickname == null
                      ? '참가 대기 중'
                      : guestReady
                          ? '준비 완료'
                          : '준비중',
                  icon: widget.guestNickname == null
                      ? Icons.person_outline
                      : Icons.person,
                  isReady: guestReady,
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
                  text: widget.isHost
                      ? '게임 시작하기'
                      : guestReady
                          ? '준비 완료'
                          : '준비하기',
                  icon: widget.isHost
                      ? Icons.play_arrow
                      : guestReady
                          ? Icons.check
                          : Icons.check_circle_outline,
                  enabled: true,
                  onTap: () {
                    if (!widget.isHost) {
                      if (guestReady) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TurnIntroScreen(
                              attackerName: widget.hostNickname,
                              guesserName: widget.guestNickname ?? 'Player B',
                              isSigner: false,
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        guestReady = true;
                      });
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TurnIntroScreen(
                          attackerName: widget.hostNickname,
                          guesserName: widget.guestNickname ?? 'Player B',
                          isSigner: true,
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
  final String guesserName;
  final bool isSigner;
  final int attackTurn;
  final String? firstPlayerName;
  final String? secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;

  const TurnIntroScreen({
    super.key,
    required this.attackerName,
    this.guesserName = 'Player B',
    required this.isSigner,
    this.attackTurn = 1,
    this.firstPlayerName,
    this.secondPlayerName,
    this.firstPlayerScore = 0,
    this.secondPlayerScore = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currentPlayerName = isSigner ? attackerName : guesserName;
    final currentRole = isSigner ? '표현자' : '정답자';
    final gameFirstPlayerName = firstPlayerName ?? attackerName;
    final gameSecondPlayerName = secondPlayerName ?? guesserName;

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
                  '$currentPlayerName님 차례 준비!',
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
                  isSigner
                      ? '이번 턴에서는 $attackerName님이 수어를 표현합니다.\n제시어를 확인하고 동작을 시작해주세요.'
                      : '이번 턴에서는 $attackerName님의 수어를 보고\n$guesserName님이 정답을 맞힙니다.',
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
                      value: guesserName,
                    ),
                    SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: isSigner ? Icons.sign_language : Icons.edit,
                      title: '내 역할',
                      value: currentRole,
                    ),
                    SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.swap_horiz,
                      title: '공격 순서',
                      value: '$attackTurn / 2',
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

              if (isSigner)
                _PrimaryButton(
                  text: '표현자 화면 시작',
                  icon: Icons.sign_language,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignerGameScreen(
                          playerName: attackerName,
                          guesserName: guesserName,
                          attackTurn: attackTurn,
                          firstPlayerName: gameFirstPlayerName,
                          secondPlayerName: gameSecondPlayerName,
                          firstPlayerScore: firstPlayerScore,
                          secondPlayerScore: secondPlayerScore,
                        ),
                      ),
                    );
                  },
                )
              else
                _PrimaryButton(
                  text: '정답자 화면 시작',
                  icon: Icons.edit,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuesserGameScreen(
                          guesserName: guesserName,
                          signerName: attackerName,
                          attackTurn: attackTurn,
                          firstPlayerName: gameFirstPlayerName,
                          secondPlayerName: gameSecondPlayerName,
                          firstPlayerScore: firstPlayerScore,
                          secondPlayerScore: secondPlayerScore,
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
  final int attackTurn;
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;

  const GuesserGameScreen({
    super.key,
    required this.guesserName,
    required this.signerName,
    required this.attackTurn,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
  });

  @override
  State<GuesserGameScreen> createState() => _GuesserGameScreenState();
}

class _GuesserGameScreenState extends State<GuesserGameScreen> {
  final TextEditingController answerController = TextEditingController();
  static const int totalRound = 5;
  static const int timeLeft = 30;
  int currentRound = 1;
  late int score;

  @override
  void initState() {
    super.initState();
    score = widget.guesserName == widget.firstPlayerName
        ? widget.firstPlayerScore
        : widget.secondPlayerScore;
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final answer = answerController.text.trim();

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정답을 입력해주세요.')),
      );
      return;
    }

    final nextScore = score + 1;
    final updatedFirstPlayerScore = widget.guesserName == widget.firstPlayerName
        ? nextScore
        : widget.firstPlayerScore;
    final updatedSecondPlayerScore =
        widget.guesserName == widget.secondPlayerName
            ? nextScore
            : widget.secondPlayerScore;

    if (currentRound >= totalRound) {
      if (widget.attackTurn >= 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              firstPlayerName: widget.firstPlayerName,
              secondPlayerName: widget.secondPlayerName,
              firstPlayerScore: updatedFirstPlayerScore,
              secondPlayerScore: updatedSecondPlayerScore,
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSwapScreen(
            previousSignerName: widget.signerName,
            previousGuesserName: widget.guesserName,
            nextPlayerIsSigner: true,
            attackTurn: widget.attackTurn + 1,
            firstPlayerName: widget.firstPlayerName,
            secondPlayerName: widget.secondPlayerName,
            firstPlayerScore: updatedFirstPlayerScore,
            secondPlayerScore: updatedSecondPlayerScore,
          ),
        ),
      );
      return;
    }

    setState(() {
      score = nextScore;
      currentRound += 1;
      answerController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('정답입니다! $currentRound라운드로 넘어갑니다.')),
    );
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
                  onTap: _submitAnswer,
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

class RoleSwapScreen extends StatelessWidget {
  final String previousSignerName;
  final String previousGuesserName;
  final bool nextPlayerIsSigner;
  final int attackTurn;
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;

  const RoleSwapScreen({
    super.key,
    required this.previousSignerName,
    required this.previousGuesserName,
    required this.nextPlayerIsSigner,
    required this.attackTurn,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
  });

  @override
  Widget build(BuildContext context) {
    final nextSignerName = previousGuesserName;
    final nextGuesserName = previousSignerName;
    final nextRole = nextPlayerIsSigner ? '표현자' : '정답자';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '공수교대',
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
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              const Center(
                child: Text(
                  '공수교대!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  '$previousSignerName님의 5라운드가 끝났어요.\n이제 $nextSignerName님이 수어를 표현합니다.',
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
                      title: '다음 표현자',
                      value: nextSignerName,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.edit,
                      title: '다음 정답자',
                      value: nextGuesserName,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: nextPlayerIsSigner ? Icons.sign_language : Icons.edit,
                      title: '내 다음 역할',
                      value: nextRole,
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.stars,
                      title: firstPlayerName,
                      value: '$firstPlayerScore점',
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.stars,
                      title: secondPlayerName,
                      value: '$secondPlayerScore점',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              _PrimaryButton(
                text: nextPlayerIsSigner ? '표현자 턴 시작' : '정답자 턴 시작',
                icon: nextPlayerIsSigner ? Icons.sign_language : Icons.edit,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TurnIntroScreen(
                        attackerName: nextSignerName,
                        guesserName: nextGuesserName,
                        isSigner: nextPlayerIsSigner,
                        attackTurn: attackTurn,
                        firstPlayerName: firstPlayerName,
                        secondPlayerName: secondPlayerName,
                        firstPlayerScore: firstPlayerScore,
                        secondPlayerScore: secondPlayerScore,
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

class ResultScreen extends StatelessWidget {
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;

  const ResultScreen({
    super.key,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
  });

  @override
  Widget build(BuildContext context) {
    final isDraw = firstPlayerScore == secondPlayerScore;
    final winnerName = firstPlayerScore > secondPlayerScore
        ? firstPlayerName
        : secondPlayerName;
    final resultTitle = isDraw ? '무승부!' : '$winnerName 승리!';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '게임 결과',
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
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Center(
                child: Text(
                  resultTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E3A),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  '각자 한 번씩 공격과 수비를 마쳤어요.\n최종 점수를 확인해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                      icon: Icons.person,
                      title: firstPlayerName,
                      value: '$firstPlayerScore점',
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.person,
                      title: secondPlayerName,
                      value: '$secondPlayerScore점',
                    ),
                    const SizedBox(height: 18),
                    _TurnInfoItem(
                      icon: Icons.flag,
                      title: '결과',
                      value: isDraw ? '무승부' : '$winnerName 승리',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              _PrimaryButton(
                text: '홈으로 돌아가기',
                icon: Icons.home,
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
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

class SignerGameScreen extends StatefulWidget {
  final String playerName;
  final String guesserName;
  final int attackTurn;
  final String firstPlayerName;
  final String secondPlayerName;
  final int firstPlayerScore;
  final int secondPlayerScore;

  const SignerGameScreen({
    super.key,
    required this.playerName,
    required this.guesserName,
    required this.attackTurn,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
  });

  @override
  State<SignerGameScreen> createState() => _SignerGameScreenState();
}

class _SignerGameScreenState extends State<SignerGameScreen> {
  static const int totalRound = 5;
  static const int timeLeft = 30;
  int currentRound = 1;
  late String currentWord;

  @override
  void initState() {
    super.initState();
    currentWord = generateRandomWord();
  }

  void _completeRound() {
    if (currentRound >= totalRound) {
      if (widget.attackTurn >= 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              firstPlayerName: widget.firstPlayerName,
              secondPlayerName: widget.secondPlayerName,
              firstPlayerScore: widget.firstPlayerScore,
              secondPlayerScore: widget.secondPlayerScore,
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSwapScreen(
            previousSignerName: widget.playerName,
            previousGuesserName: widget.guesserName,
            nextPlayerIsSigner: false,
            attackTurn: widget.attackTurn + 1,
            firstPlayerName: widget.firstPlayerName,
            secondPlayerName: widget.secondPlayerName,
            firstPlayerScore: widget.firstPlayerScore,
            secondPlayerScore: widget.secondPlayerScore,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentRound += 1;
      currentWord = generateRandomWord();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$currentRound라운드 제시어로 넘어갑니다.')),
    );
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
                  '${widget.playerName}님 차례예요',
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
                  onTap: _completeRound,
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
