import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCTestScreen extends StatefulWidget {
  const WebRTCTestScreen({super.key});

  @override
  State<WebRTCTestScreen> createState() => _WebRTCTestScreenState();
}

class _WebRTCTestScreenState extends State<WebRTCTestScreen> {
  RTCVideoRenderer _renderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    await _renderer.initialize();

    final stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': false,
    });

    setState(() {
      _renderer.srcObject = stream;
    });
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RTCVideoView(_renderer),
    );
  }
}