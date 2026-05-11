import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;

  final Map<String, dynamic> config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}
    ]
  };

  /// 1️⃣ 로컬 카메라 가져오기
  Future<MediaStream> startLocalStream() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': false, // 지금은 카메라만
    });

    localStream = stream;
    return stream;
  }

  /// 2️⃣ PeerConnection 생성
  Future<void> createPeerConnection() async {
    _peerConnection = await createPeerConnection(config);

    // ICE candidate 처리
    _peerConnection!.onIceCandidate = (candidate) {
      print("ICE: ${candidate.candidate}");
      // 👉 나중에 서버로 보낼 값
    };

    // 상대방 스트림 받기
    _peerConnection!.onTrack = (event) {
      print("Remote stream received");
    };

    // 로컬 스트림 추가
    if (localStream != null) {
      for (var track in localStream!.getTracks()) {
        _peerConnection!.addTrack(track, localStream!);
      }
    }
  }

  /// 3️⃣ Offer 생성 (1P)
  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  /// 4️⃣ Answer 생성 (2P)
  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  /// 5️⃣ remote description 설정
  Future<void> setRemoteDescription(RTCSessionDescription desc) async {
    await _peerConnection!.setRemoteDescription(desc);
  }

  void dispose() {
    localStream?.dispose();
    _peerConnection?.close();
  }
}