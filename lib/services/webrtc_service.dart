import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  RTCDataChannel? _dataChannel;
  final List<StreamSubscription> _subscriptions = [];
  bool _hasRemoteDescription = false;

  Function(String localFilePath)? onVideoReceived;

  final Map<String, dynamic> config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'turn:global.relay.metered.ca:80', 'username': '25452eaaf05c922813425834', 'credential': '0yoQuw9ne80r6bJ3'},
      {'urls': 'turn:global.relay.metered.ca:443', 'username': '25452eaaf05c922813425834', 'credential': '0yoQuw9ne80r6bJ3'},
    ]
  };

  void _setupConnectionListeners() {
    peerConnection?.onConnectionState = (s) => print("PC STATE: $s");
    peerConnection?.onIceConnectionState = (s) => print("ICE STATE: $s");
  }

  Future<void> startSigner(String roomCode) async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomCode);
    await _resetConnection();
    await _clearCandidates(roomRef, 'callerCandidates');
    await _clearCandidates(roomRef, 'calleeCandidates');
    await roomRef.update({'offer': FieldValue.delete(), 'answer': FieldValue.delete()});

    peerConnection = await createPeerConnection(config);
    _setupConnectionListeners();

    RTCDataChannelInit init = RTCDataChannelInit()..ordered = true;
    _dataChannel = await peerConnection!.createDataChannel('video', init);
    _dataChannel?.onDataChannelState = (s) => print("DC STATE: $s");

    peerConnection!.onIceCandidate = (c) => _addCandidate(roomRef.collection('callerCandidates'), c);

    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    await roomRef.update({'offer': offer.toMap()});

    _subscriptions.add(roomRef.snapshots().listen((snap) async {
      final answer = snap.data()?['answer'];
      if (!_hasRemoteDescription && answer != null) {
        await peerConnection!.setRemoteDescription(RTCSessionDescription(answer['sdp'], answer['type']));
        _hasRemoteDescription = true;
      }
    }));
  }

  Future<void> startGuesser(String roomCode, RTCVideoRenderer renderer) async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomCode);
    await _resetConnection();
    peerConnection = await createPeerConnection(config);
    _setupConnectionListeners();

    peerConnection!.onDataChannel = (channel) => _setupDataChannelReceiver(channel);
    peerConnection!.onIceCandidate = (c) => _addCandidate(roomRef.collection('calleeCandidates'), c);

    _subscriptions.add(roomRef.snapshots().listen((snap) async {
      final offer = snap.data()?['offer'];
      if (!_hasRemoteDescription && offer != null) {
        await peerConnection!.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));
        _hasRemoteDescription = true;
        
        final answer = await peerConnection!.createAnswer();
        await peerConnection!.setLocalDescription(answer);
        await roomRef.update({'answer': answer.toMap()});
      }
    }));

    _subscriptions.add(roomRef.collection('callerCandidates').snapshots().listen((snap) {
      for (final change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final d = change.doc.data() as Map<String, dynamic>;
          peerConnection?.addCandidate(RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
        }
      }
    }));
  }

  Future<void> sendVideoFile(String filePath) async {
  // 1. 채널 복사
  final channel = _dataChannel;
  
  // 2. 널 체크 (이 코드가 있으면 아래 루프에서 !를 쓸 필요가 없습니다)
  if (channel == null) {
    print("전송 실패: 채널이 없습니다.");
    return;
  }

  // 연결 상태 확인
  int retry = 0;
  while (channel.state != RTCDataChannelState.RTCDataChannelOpen && retry < 50) {
    await Future.delayed(const Duration(milliseconds: 100));
    retry++;
  }

  final file = File(filePath);
  final bytes = await file.readAsBytes();
  const int chunkSize = 16384;

  channel.send(RTCDataChannelMessage('START_FILE'));

  for (int i = 0; i < bytes.length; i += chunkSize) {
    // 💡 3. 이제 !가 필요 없습니다! (위에서 확실히 널 아님을 보장했기 때문)
    while ((channel.bufferedAmount ?? 0) > 1024 * 1024) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
    channel.send(RTCDataChannelMessage.fromBinary(bytes.sublist(i, end)));
  }

  channel.send(RTCDataChannelMessage('END_FILE'));
}

  void _setupDataChannelReceiver(RTCDataChannel channel) {
    _dataChannel = channel;
    BytesBuilder builder = BytesBuilder();
    _dataChannel!.onMessage = (msg) async {
      if (!msg.isBinary) {
        if (msg.text == 'END_FILE') {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4');
          await file.writeAsBytes(builder.takeBytes());
          onVideoReceived?.call(file.path);
        }
      } else { builder.add(msg.binary); }
    };
  }

  Future<void> _addCandidate(CollectionReference ref, RTCIceCandidate c) async {
    try {
      final data = c.toMap()..['timestamp'] = FieldValue.serverTimestamp();
      await ref.add(data);
    } catch (e) { print("ICE 저장 실패: $e"); }
  }

  Future<void> _resetConnection() async {
    for (final s in _subscriptions) await s.cancel();
    _subscriptions.clear();
    _hasRemoteDescription = false;
    await _dataChannel?.close();
    await peerConnection?.close();
    peerConnection = null;
    _dataChannel = null;
  }

  Future<void> _clearCandidates(DocumentReference ref, String col) async {
    final snap = await ref.collection(col).get();
    for (final doc in snap.docs) await doc.reference.delete();
  }
}