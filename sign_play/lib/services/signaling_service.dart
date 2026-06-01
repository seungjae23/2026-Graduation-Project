import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SignalingService {
  late WebSocketChannel channel;

  void connect(String roomId) {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://YOUR_SERVER/ws/room/$roomId'),
    );

    channel.stream.listen((message) {
      final data = jsonDecode(message);
      print("받은 메시지: $data");
    });
  }

  void send(Map<String, dynamic> msg) {
    channel.sink.add(jsonEncode(msg));
  }
}