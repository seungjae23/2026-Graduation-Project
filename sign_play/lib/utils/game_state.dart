part of sign_play;

const int gameTotalRounds = 5;
const int gameRoundSeconds = 30;

const String roomStatusWaiting = 'waiting';
const String roomStatusPlaying = 'playing';
const String roomStatusFinished = 'finished';

const String gamePhaseTurnIntro = 'turnIntro';
const String gamePhasePlaying = 'playing';
const String gamePhaseRoleSwap = 'roleSwap';
const String gamePhaseFinished = 'finished';

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
  bool get isFinalRound => currentRound >= gameTotalRounds;

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
    roundWords: _stringListFromFirestore(gameData['roundWords']),
    roundStartedAt: gameData['roundStartedAt'] as Timestamp?,
    lastAnswerCorrect: lastAnswer?['isCorrect'] as bool?,
    lastAnswerAttackTurn: lastAnswer?['attackTurn'] as int?,
    lastAnswerRound: lastAnswer?['round'] as int?,
  );
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
}) {
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
    'roundWords': generateRoundWords(seed: '$roomCode-1'),
    'roundStartedAt': null,
    'lastAnswer': null,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

Future<void> startSyncedGame({
  required String roomCode,
  required String firstPlayerName,
  required String secondPlayerName,
}) {
  return roomDocument(roomCode).update({
    'status': roomStatusPlaying,
    'startedAt': FieldValue.serverTimestamp(),
    'game': initialGameStateData(
      roomCode: roomCode,
      firstPlayerName: firstPlayerName,
      secondPlayerName: secondPlayerName,
    ),
  });
}

Future<void> startSyncedTurn(String roomCode) {
  return roomDocument(roomCode).update({
    'game.phase': gamePhasePlaying,
    'game.roundStartedAt': FieldValue.serverTimestamp(),
    'game.updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> openSyncedTurnIntro(String roomCode) {
  return roomDocument(roomCode).update({
    'game.phase': gamePhaseTurnIntro,
    'game.roundStartedAt': null,
    'game.updatedAt': FieldValue.serverTimestamp(),
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
          'game.roundWords': generateRoundWords(
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
