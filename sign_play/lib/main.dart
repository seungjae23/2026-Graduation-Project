library sign_play;

import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

part 'screens/home_screen.dart';
part 'screens/create_room_screen.dart';
part 'screens/join_room_screen.dart';
part 'screens/camera_test_screen.dart';
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
part 'utils/words.dart';

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
