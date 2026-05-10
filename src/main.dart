import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late WebSocketChannel channel;

  int score = 0;
  String target = "OPEN";
  String last = "CLOSE";
  bool connected = false;

  @override
  void initState() {
    super.initState();

    // ⚠️ 같은 PC면 127.0.0.1, 폰이면 IP 주소로 변경
    channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/ws'),
    );

    channel.stream.listen((message) {
      final data = jsonDecode(message);

      setState(() {
        score = data["score"];
        target = data["target"];
        last = data["last"];
        connected = true;
      });
    }, onError: (error) {
      print("❌ 오류: $error");
    }, onDone: () {
      print("🔴 연결 종료");
      connected = false;
    });
  }

  void sendAction(String action) {
    channel.sink.add(jsonEncode({
      "action": action
    }));
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Color getColor() {
    return last == "OPEN" ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Hand Game"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: connected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // 🎯 목표
                  Text(
                    "TARGET",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    target,
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 30),

                  // 🧠 결과
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: getColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      last,
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // 💯 점수
                  Text(
                    "SCORE",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "$score",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 40),

                  // 🎮 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => sendAction("OPEN"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                        ),
                        child: Text("OPEN"),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => sendAction("CLOSE"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                        ),
                        child: Text("CLOSE"),
                      ),
                    ],
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}