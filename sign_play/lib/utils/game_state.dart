part of sign_play;

const int gameDefaultTotalRounds = 5;
const int gameMinTotalRounds = 2;
const int gameMaxTotalRounds = 10;
const int gameTotalRounds = gameDefaultTotalRounds;
const int gameRoundSeconds = 30;

const String roomStatusWaiting = 'waiting';
const String roomStatusPlaying = 'playing';
const String roomStatusFinished = 'finished';
const String roomStatusAborted = 'aborted';

const String gamePhaseTurnIntro = 'turnIntro';
const String gamePhasePlaying = 'playing';
const String gamePhaseRoleSwap = 'roleSwap';
const String gamePhaseFinished = 'finished';
const String gamePhaseAborted = 'aborted';

class GameState {
  final String phase;
  final int attackTurn;
  final int currentRound;
  final String firstPlayerName;
  final String secondPlayerName;
  final String signerName;
  final String guesserName;
  final int firstPlayerScore;
  final int secondPlayerScore;
  final int totalRounds;
  final bool signerReady;
  final bool guesserReady;
  final List<String> roundWords;
  final Timestamp? roundStartedAt;
  final bool? lastAnswerCorrect;
  final int? lastAnswerAttackTurn;
  final int? lastAnswerRound;

  const GameState({
    required this.phase,
    required this.attackTurn,
    required this.currentRound,
    required this.firstPlayerName,
    required this.secondPlayerName,
    required this.signerName,
    required this.guesserName,
    required this.firstPlayerScore,
    required this.secondPlayerScore,
    required this.totalRounds,
    required this.signerReady,
    required this.guesserReady,
    required this.roundWords,
    required this.roundStartedAt,
    required this.lastAnswerCorrect,
    required this.lastAnswerAttackTurn,
    required this.lastAnswerRound,
  });

  String get currentWord {
    if (currentRound <= roundWords.length) {
      return roundWords[currentRound - 1];
    }

    return generateRandomWord();
  }

  int remainingSeconds(DateTime now) {
    final startedAt = roundStartedAt;

    if (startedAt == null) {
      return gameRoundSeconds;
    }

    final elapsedSeconds = now.difference(startedAt.toDate()).inSeconds;
    return max(0, gameRoundSeconds - elapsedSeconds);
  }

  bool get isFinalAttackTurn => attackTurn >= 2;
  bool get isFinalRound => currentRound >= totalRounds;

  String? get answerFeedbackKey {
    final isCorrect = lastAnswerCorrect;
    final attackTurn = lastAnswerAttackTurn;
    final round = lastAnswerRound;

    if (isCorrect == null || attackTurn == null || round == null) {
      return null;
    }

    return '$attackTurn-$round-$isCorrect';
  }
}

DocumentReference<Map<String, dynamic>> roomDocument(String roomCode) {
  return FirebaseFirestore.instance.collection('rooms').doc(roomCode);
}

GameState? gameStateFromRoomData(Map<String, dynamic>? roomData) {
  if (roomData == null) {
    return null;
  }

  final gameData = roomData['game'];

  if (gameData is! Map<String, dynamic>) {
    return null;
  }

  final lastAnswerData = gameData['lastAnswer'];
  final lastAnswer = lastAnswerData is Map<String, dynamic>
      ? lastAnswerData
      : null;

  final roundWords = _stringListFromFirestore(gameData['roundWords']);
  final totalRounds = roundCountFromRoomData(
    roomData,
    fallback: roundWords.isEmpty ? gameDefaultTotalRounds : roundWords.length,
  );

  return GameState(
    phase: gameData['phase'] as String? ?? gamePhaseTurnIntro,
    attackTurn: gameData['attackTurn'] as int? ?? 1,
    currentRound: gameData['currentRound'] as int? ?? 1,
    firstPlayerName:
        (gameData['firstPlayerName'] as String?) ??
        (roomData['hostNickname'] as String?) ??
        'Player A',
    secondPlayerName:
        (gameData['secondPlayerName'] as String?) ??
        (roomData['playerB'] as String?) ??
        'Player B',
    signerName:
        (gameData['signerName'] as String?) ??
        (roomData['hostNickname'] as String?) ??
        'Player A',
    guesserName:
        (gameData['guesserName'] as String?) ??
        (roomData['playerB'] as String?) ??
        'Player B',
    firstPlayerScore: gameData['firstPlayerScore'] as int? ?? 0,
    secondPlayerScore: gameData['secondPlayerScore'] as int? ?? 0,
    totalRounds: totalRounds,
    signerReady: gameData['signerReady'] as bool? ?? false,
    guesserReady: gameData['guesserReady'] as bool? ?? false,
    roundWords: roundWords,
    roundStartedAt: gameData['roundStartedAt'] as Timestamp?,
    lastAnswerCorrect: lastAnswer?['isCorrect'] as bool?,
    lastAnswerAttackTurn: lastAnswer?['attackTurn'] as int?,
    lastAnswerRound: lastAnswer?['round'] as int?,
  );
}

int normalizeRoundCount(int roundCount) {
  return roundCount.clamp(gameMinTotalRounds, gameMaxTotalRounds).toInt();
}

int roundCountFromWords(List<String>? roundWords) {
  final wordCount = roundWords?.length ?? gameDefaultTotalRounds;

  if (wordCount == 0) {
    return gameDefaultTotalRounds;
  }

  return normalizeRoundCount(wordCount);
}

int roundCountFromRoomData(
  Map<String, dynamic>? roomData, {
  int fallback = gameDefaultTotalRounds,
}) {
  if (roomData == null) {
    return normalizeRoundCount(fallback);
  }

  final gameData = roomData['game'];
  final gameRoundCount = gameData is Map<String, dynamic>
      ? gameData['totalRounds']
      : null;
  final roomRoundCount = roomData['totalRounds'];
  final rawRoundCount = gameRoundCount ?? roomRoundCount;

  if (rawRoundCount is int) {
    return normalizeRoundCount(rawRoundCount);
  }

  if (rawRoundCount is num) {
    return normalizeRoundCount(rawRoundCount.toInt());
  }

  return normalizeRoundCount(fallback);
}

List<String> _stringListFromFirestore(Object? value) {
  if (value is List) {
    return value.whereType<String>().toList();
  }

  return const [];
}

Map<String, dynamic> initialGameStateData({
  required String roomCode,
  required String firstPlayerName,
  required String secondPlayerName,
  required int totalRounds,
}) {
  final normalizedTotalRounds = normalizeRoundCount(totalRounds);

  return {
    'phase': gamePhaseTurnIntro,
    'attackTurn': 1,
    'currentRound': 1,
    'firstPlayerName': firstPlayerName,
    'secondPlayerName': secondPlayerName,
    'signerName': firstPlayerName,
    'guesserName': secondPlayerName,
    'firstPlayerScore': 0,
    'secondPlayerScore': 0,
    'totalRounds': normalizedTotalRounds,
    'signerReady': false,
    'guesserReady': false,
    'roundWords': generateRoundWords(
      count: normalizedTotalRounds,
      seed: '$roomCode-1',
    ),
    'roundStartedAt': null,
    'lastAnswer': null,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

Future<void> startSyncedGame({
  required String roomCode,
  required String firstPlayerName,
  required String secondPlayerName,
  required int totalRounds,
}) {
  final normalizedTotalRounds = normalizeRoundCount(totalRounds);

  return roomDocument(roomCode).update({
    'status': roomStatusPlaying,
    'startedAt': FieldValue.serverTimestamp(),
    'game': initialGameStateData(
      roomCode: roomCode,
      firstPlayerName: firstPlayerName,
      secondPlayerName: secondPlayerName,
      totalRounds: normalizedTotalRounds,
    ),
  });
}

Future<void> setSyncedTurnReady({
  required String roomCode,
  required bool isSigner,
  required bool isReady,
}) {
  final roomRef = roomDocument(roomCode);

  return FirebaseFirestore.instance.runTransaction<void>((transaction) async {
    final snapshot = await transaction.get(roomRef);
    final roomData = snapshot.data();
    final gameData = roomData?['game'];

    if (roomData == null ||
        roomData['status'] != roomStatusPlaying ||
        gameData is! Map<String, dynamic> ||
        gameData['phase'] != gamePhaseTurnIntro) {
      return;
    }

    final signerReady = isSigner
        ? isReady
        : (gameData['signerReady'] as bool? ?? false);
    final guesserReady = isSigner
        ? (gameData['guesserReady'] as bool? ?? false)
        : isReady;

    final update = <String, dynamic>{
      'game.signerReady': signerReady,
      'game.guesserReady': guesserReady,
      'game.updatedAt': FieldValue.serverTimestamp(),
    };

    if (signerReady && guesserReady) {
      update.addAll({
        'game.phase': gamePhasePlaying,
        'game.roundStartedAt': FieldValue.serverTimestamp(),
      });
    }

    transaction.update(roomRef, update);
  });
}

Future<void> openSyncedTurnIntro(String roomCode) {
  return roomDocument(roomCode).update({
    'game.phase': gamePhaseTurnIntro,
    'game.signerReady': false,
    'game.guesserReady': false,
    'game.roundStartedAt': null,
    'game.updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> abortSyncedGame({
  required String roomCode,
  required String leftPlayerName,
}) {
  final roomRef = roomDocument(roomCode);

  return FirebaseFirestore.instance.runTransaction<void>((transaction) async {
    final snapshot = await transaction.get(roomRef);
    final roomData = snapshot.data();
    final status = roomData?['status'] as String?;

    if (roomData == null || status != roomStatusPlaying) {
      return;
    }

    transaction.update(roomRef, {
      'status': roomStatusAborted,
      'leftPlayerName': leftPlayerName,
      'abortedAt': FieldValue.serverTimestamp(),
      'game.phase': gamePhaseAborted,
      'game.roundStartedAt': null,
      'game.updatedAt': FieldValue.serverTimestamp(),
    });
  });
}

bool wasRoomAbortedByOpponent(
  Map<String, dynamic>? roomData,
  String currentPlayerName,
) {
  if (roomData == null || roomData['status'] != roomStatusAborted) {
    return false;
  }

  final leftPlayerName = roomData['leftPlayerName'] as String?;

  return leftPlayerName == null ||
      leftPlayerName.isEmpty ||
      leftPlayerName != currentPlayerName;
}

String opponentExitMessage(Map<String, dynamic>? roomData) {
  final leftPlayerName = roomData?['leftPlayerName'] as String?;

  if (leftPlayerName == null || leftPlayerName.isEmpty) {
    return '상대방이 게임을 나갔습니다.';
  }

  return '$leftPlayerName님이 게임을 나갔습니다.';
}

void moveToHomeAfterOpponentExit(
  BuildContext context, {
  required String message,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    navigator.popUntil((route) => route.isFirst);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  });
}

Future<bool> completeSyncedRound({
  required String roomCode,
  required int expectedAttackTurn,
  required int expectedRound,
  required int firstPlayerScore,
  required int secondPlayerScore,
  required bool answerWasCorrect,
}) {
  final roomRef = roomDocument(roomCode);

  return FirebaseFirestore.instance.runTransaction<bool>((transaction) async {
    final snapshot = await transaction.get(roomRef);
    final gameState = gameStateFromRoomData(snapshot.data());

    if (gameState == null ||
        gameState.phase != gamePhasePlaying ||
        gameState.attackTurn != expectedAttackTurn ||
        gameState.currentRound != expectedRound) {
      return false;
    }

    final update = <String, dynamic>{
      'game.firstPlayerScore': firstPlayerScore,
      'game.secondPlayerScore': secondPlayerScore,
      'game.lastAnswer': {
        'attackTurn': expectedAttackTurn,
        'round': expectedRound,
        'isCorrect': answerWasCorrect,
        'answeredAt': FieldValue.serverTimestamp(),
      },
      'game.updatedAt': FieldValue.serverTimestamp(),
    };

    if (gameState.isFinalRound) {
      if (gameState.isFinalAttackTurn) {
        update.addAll({
          'status': roomStatusFinished,
          'game.phase': gamePhaseFinished,
          'game.roundStartedAt': null,
        });
      } else {
        final nextAttackTurn = gameState.attackTurn + 1;

        update.addAll({
          'game.phase': gamePhaseRoleSwap,
          'game.attackTurn': nextAttackTurn,
          'game.currentRound': 1,
          'game.signerName': gameState.secondPlayerName,
          'game.guesserName': gameState.firstPlayerName,
          'game.totalRounds': gameState.totalRounds,
          'game.signerReady': false,
          'game.guesserReady': false,
          'game.roundWords': generateRoundWords(
            count: gameState.totalRounds,
            seed: '$roomCode-$nextAttackTurn',
          ),
          'game.roundStartedAt': null,
        });
      }
    } else {
      update.addAll({
        'game.currentRound': gameState.currentRound + 1,
        'game.roundStartedAt': FieldValue.serverTimestamp(),
      });
    }

    transaction.update(roomRef, update);
    return true;
  });
}
