library sign_play;

// 1. 필요한 모든 라이브러리 import
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:collection';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:collection/collection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// 2. 프로젝트 설정 파일 import
import 'firebase_options.dart';
import 'services/webrtc_service.dart';
import 'services/word_service.dart';
// 3. 각 화면 및 기능 파일들을 part로 등록
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
part 'widgets/game_header.dart';
part 'widgets/camera_recorder_widget.dart';
part 'utils/room_code.dart';
part 'services/sign_evaluation_service.dart';
part 'services/landmark_processor.dart';

// 4. 전역 서비스 선언
final WebRTCService webRTCService = WebRTCService();

// 5. 앱 실행 시작점 (여기에 딱 하나만 있어야 합니다!)
Future<void> main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 💡 앱이 켜질 때 JSON 단어장을 미리 싹 읽어둡니다!
  await WordService.init(); 

  // 앱 실행
  runApp(const SignPlayApp());
}

// 6. 메인 앱 클래스
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
      // 시작 화면
      home: const HomeScreen(), 
    );
  }
}