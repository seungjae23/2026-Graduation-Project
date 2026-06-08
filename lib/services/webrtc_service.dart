import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  RTCDataChannel? _dataChannel; // 💡 파일을 주고받을 무료 비밀 통로
  MediaStream? localStream;
  
  final List<StreamSubscription> _subscriptions = [];
  bool _hasRemoteDescription = false;

  // 💡 2P가 영상을 완벽하게 다 받으면 UI에 알려줄 콜백 함수
  Function(String localFilePath)? onVideoReceived;

  // 구글의 무료 STUN 서버를 사용해 서로의 기기를 찾습니다.
  final Map<String, dynamic> config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}
    ]
  };

  /// 1️⃣ 로컬 카메라 켜기 (표현자용)
  Future<void> initLocalStream(RTCVideoRenderer localRenderer) async {
    localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': false, // 수어 게임이므로 오디오는 끕니다
    });
    localRenderer.srcObject = localStream;
  }

  /// 2️⃣ 표현자(1P) 연결 설정: 방(Offer) 생성 및 파일 송신 통로 개척
  Future<void> startSigner(String roomCode) async {
    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('rooms').doc(roomCode);

    await _resetConnection();
    await _clearCandidates(roomRef, 'callerCandidates');
    await _clearCandidates(roomRef, 'calleeCandidates');
    await roomRef.update({
      'offer': FieldValue.delete(),
      'answer': FieldValue.delete(),
    });

    peerConnection = await createPeerConnection(config);

    // 💡 [핵심] Offer를 만들기 전에 파일 전송용 DataChannel을 먼저 뚫습니다!
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()..maxRetransmits = 30;
    _dataChannel = await peerConnection!.createDataChannel('video_transfer', dataChannelDict);

    // 내 카메라 스트림을 WebRTC에 추가
    if (localStream != null) {
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });
    }

    // 통신 통로(ICE Candidate) 수집 및 파이어베이스에 저장
    peerConnection!.onIceCandidate = (candidate) {
      _addCandidate(roomRef.collection('callerCandidates'), candidate);
    };

    // 연결 요청서(Offer) 생성 및 파이어베이스 저장
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    await roomRef.update({'offer': offer.toMap()});

    // 2P가 요청을 수락(Answer)하면 감지해서 연결
    _subscriptions.add(roomRef.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      final answerData = data?['answer'];

      if (!_hasRemoteDescription && answerData != null) {
        var answer = RTCSessionDescription(answerData['sdp'], answerData['type']);
        await peerConnection?.setRemoteDescription(answer);
        _hasRemoteDescription = true;
      }
    }));

    // 2P의 통신 통로 감지해서 적용
    _subscriptions.add(roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          peerConnection!.addCandidate(RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
        }
      }
    }));
  }

  /// 3️⃣ 정답자(2P) 연결 설정: 연결 수락(Answer) 및 파일 수신 대기
  Future<void> startGuesser(String roomCode, RTCVideoRenderer remoteRenderer) async {
    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('rooms').doc(roomCode);
    final roomSnapshot = await roomRef.get();

    if (!roomSnapshot.exists) return;

    await _resetConnection();
    peerConnection = await createPeerConnection(config);

    // 💡 [핵심] 1P가 뚫어놓은 DataChannel이 연결되면 수신 준비를 합니다!
    peerConnection!.onDataChannel = (RTCDataChannel channel) {
      _setupDataChannelReceiver(channel);
    };

    // 1P의 실시간 스트림이 들어오면 화면에 연결 (라이브 화면용)
    peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    // 통신 통로(ICE Candidate) 수집 및 파이어베이스 저장
    peerConnection!.onIceCandidate = (candidate) {
      _addCandidate(roomRef.collection('calleeCandidates'), candidate);
    };

    // 1P가 만든 요청서(Offer) 가져와서 적용
    final data = roomSnapshot.data();
    final offerData = data?['offer'];
    if (offerData != null) {
      var offer = RTCSessionDescription(offerData['sdp'], offerData['type']);
      await peerConnection?.setRemoteDescription(offer);
      _hasRemoteDescription = true;

      // 수락서(Answer) 생성 및 저장
      RTCSessionDescription answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);
      await roomRef.update({'answer': answer.toMap()});
    }

    // 1P의 통신 통로 감지해서 적용
    _subscriptions.add(roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          peerConnection!.addCandidate(RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
        }
      }
    }));
  }

  /// 💡 [추가 기능] 2P가 1P의 영상 파일을 조각조각 받아서 .mp4로 조립하는 함수
  void _setupDataChannelReceiver(RTCDataChannel channel) {
    _dataChannel = channel;
    List<int> receiveBuffer = [];

    _dataChannel!.onMessage = (RTCDataChannelMessage message) async {
      if (!message.isBinary) {
        // 텍스트 신호 처리
        if (message.text == 'START_FILE') {
          receiveBuffer.clear(); // 새 파일 받기 전 버퍼 비우기
        } else if (message.text == 'END_FILE') {
          // 영상 조각 모음 완료! 임시 폴더에 .mp4 파일로 저장
          Directory tempDir = await getTemporaryDirectory();
          File tempVideo = File('${tempDir.path}/received_video.mp4');
          await tempVideo.writeAsBytes(receiveBuffer);
          
          // 화면(UI)쪽에 "영상 다 받았으니 재생해라!" 라고 파일 경로 전달
          onVideoReceived?.call(tempVideo.path);
        }
      } else {
        // 영상 조각(바이너리)이 도착할 때마다 차곡차곡 쌓기
        receiveBuffer.addAll(message.binary);
      }
    };
  }

  /// 💡 [추가 기능] 1P가 녹화한 .mp4 파일을 쪼개서 2P에게 다이렉트로 발사하는 함수
  Future<void> sendVideoFile(String filePath) async {
    if (_dataChannel == null) return;
    
    File videoFile = File(filePath);
    Uint8List bytes = await videoFile.readAsBytes();
    
    // WebRTC가 터지지 않게 한 번에 64KB씩 안전하게 잘라서 보냅니다.
    int chunkSize = 65535; 
    int offset = 0;

    // 2P에게 "지금부터 파일 보낸다!" 신호 전송
    _dataChannel!.send(RTCDataChannelMessage('START_FILE'));

    while (offset < bytes.length) {
      int end = (offset + chunkSize < bytes.length) ? offset + chunkSize : bytes.length;
      Uint8List chunk = bytes.sublist(offset, end);
      
      _dataChannel!.send(RTCDataChannelMessage.fromBinary(chunk));
      offset = end;
      
      // 버퍼 오버플로우 방지를 위해 아주 살짝 딜레이
      await Future.delayed(const Duration(milliseconds: 5)); 
    }

    // 2P에게 "파일 전송 끝났다! 조립해라!" 신호 전송
    _dataChannel!.send(RTCDataChannelMessage('END_FILE'));
  }

  /// 자원 해제 및 유틸 함수들
  Future<void> _addCandidate(
    CollectionReference<Map<String, dynamic>> collection,
    RTCIceCandidate candidate,
  ) async {
    if (candidate.candidate == null || candidate.candidate!.isEmpty) {
      return;
    }
    await collection.add(candidate.toMap());
  }

  Future<void> _clearCandidates(
    DocumentReference<Map<String, dynamic>> roomRef,
    String collectionName,
  ) async {
    final snapshot = await roomRef.collection(collectionName).get();
    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _resetConnection() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _hasRemoteDescription = false;
    
    await _dataChannel?.close();
    _dataChannel = null;
    
    await peerConnection?.close();
    peerConnection = null;
  }

  void dispose() {
    _resetConnection();
    localStream?.getTracks().forEach((track) {
      track.stop();
    });
    localStream?.dispose();
  }
}