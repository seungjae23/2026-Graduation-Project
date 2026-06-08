// 1. 가장 먼저 지시어(Directive)들을 모두 배치합니다.
library sign_play;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:collection';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'firebase_options.dart';
import 'services/webrtc_service.dart';
import 'package:collection/collection.dart';

part 'screens/home_screen.dart';
part 'screens/create_room_screen.dart';
part 'screens/join_room_screen.dart';
part 'screens/waiting_room_screen.dart';
part 'screens/turn_intro_screen.dart';
part 'screens/guesser_game_screen.dart';
part 'screens/role_swap_screen.dart';
part 'screens/result_screen.dart';
part 'screens/signer_game_screen.dart';
part 'widgets/input_box.dart';
part 'widgets/rule_item.dart';
part 'widgets/primary_button.dart';
part 'widgets/turn_info_item.dart';
part 'widgets/status_box.dart';
part 'widgets/guide_text.dart';
part 'widgets/camera_preview_panel.dart';
part 'utils/room_code.dart';
part 'services/sign_evaluation_service.dart';
part 'services/landmark_processor.dart';

// 2. 지시어들이 다 끝나고 나서야 변수 선언(Declaration)이 나옵니다.
final WebRTCService webRTCService = WebRTCService();

// 3. 그다음 함수와 클래스들이 나옵니다.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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