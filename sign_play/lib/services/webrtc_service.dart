import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;

  final List<StreamSubscription> _subscriptions = [];
  bool _hasRemoteDescription = false;

  final Map<String, dynamic> config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  Future<void> startLocalStream(RTCVideoRenderer localRenderer) async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': false,
    });

    localStream = stream;
    localRenderer.srcObject = stream;
  }

  Future<void> startSigner(String roomCode) async {
    final roomRef = _roomDocument(roomCode);

    await _resetConnection();
    await _clearCandidates(roomRef, 'callerCandidates');
    await _clearCandidates(roomRef, 'calleeCandidates');

    await roomRef.update({
      'offer': FieldValue.delete(),
      'answer': FieldValue.delete(),
    });

    await _createPeerConnection();
    _addLocalTracks();

    _peerConnection!.onIceCandidate = (candidate) {
      _addCandidate(roomRef.collection('callerCandidates'), candidate);
    };

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await roomRef.update({'offer': offer.toMap()});

    _subscriptions.add(roomRef.snapshots().listen((snapshot) async {
      final answerData = snapshot.data()?['answer'];

      if (!_hasRemoteDescription && answerData != null) {
        final answer = RTCSessionDescription(
          answerData['sdp'] as String?,
          answerData['type'] as String?,
        );

        await _peerConnection?.setRemoteDescription(answer);
        _hasRemoteDescription = true;
      }
    }));

    _subscriptions.add(
      roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _addRemoteCandidate(change.doc.data());
          }
        }
      }),
    );
  }

  Future<void> startGuesser(
    String roomCode,
    RTCVideoRenderer remoteRenderer,
  ) async {
    final roomRef = _roomDocument(roomCode);
    final offerData = await _waitForOffer(roomRef);

    if (offerData == null) {
      return;
    }

    await _resetConnection();
    await _createPeerConnection();

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams.first;
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      _addCandidate(roomRef.collection('calleeCandidates'), candidate);
    };

    final offer = RTCSessionDescription(
      offerData['sdp'] as String?,
      offerData['type'] as String?,
    );

    await _peerConnection!.setRemoteDescription(offer);
    _hasRemoteDescription = true;

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    await roomRef.update({'answer': answer.toMap()});

    _subscriptions.add(
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _addRemoteCandidate(change.doc.data());
          }
        }
      }),
    );
  }

  Future<Map<String, dynamic>?> _waitForOffer(
    DocumentReference<Map<String, dynamic>> roomRef,
  ) async {
    final snapshot = await roomRef.snapshots().firstWhere((snapshot) {
      final data = snapshot.data();
      return snapshot.exists && data?['offer'] != null;
    }).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException('Timed out waiting for WebRTC offer.');
      },
    );

    return snapshot.data()?['offer'] as Map<String, dynamic>?;
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(config);
  }

  void _addLocalTracks() {
    final stream = localStream;

    if (stream == null) {
      return;
    }

    for (final track in stream.getTracks()) {
      _peerConnection!.addTrack(track, stream);
    }
  }

  Future<void> _addCandidate(
    CollectionReference<Map<String, dynamic>> collection,
    RTCIceCandidate candidate,
  ) async {
    if (candidate.candidate == null || candidate.candidate!.isEmpty) {
      return;
    }

    await collection.add(candidate.toMap());
  }

  void _addRemoteCandidate(Map<String, dynamic>? data) {
    if (data == null) {
      return;
    }

    _peerConnection?.addCandidate(
      RTCIceCandidate(
        data['candidate'] as String?,
        data['sdpMid'] as String?,
        data['sdpMLineIndex'] as int?,
      ),
    );
  }

  Future<void> _clearCandidates(
    DocumentReference<Map<String, dynamic>> roomRef,
    String collectionName,
  ) async {
    final snapshot = await roomRef.collection(collectionName).get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  DocumentReference<Map<String, dynamic>> _roomDocument(String roomCode) {
    return FirebaseFirestore.instance.collection('rooms').doc(roomCode);
  }

  Future<void> _resetConnection() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }

    _subscriptions.clear();
    _hasRemoteDescription = false;

    await _peerConnection?.close();
    _peerConnection = null;
  }

  void dispose() {
    unawaited(_resetConnection());

    for (final track in localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      track.stop();
    }

    localStream?.dispose();
    localStream = null;
  }
}
