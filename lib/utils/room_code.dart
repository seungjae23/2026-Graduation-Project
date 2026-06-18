part of '../main.dart';

String generateRoomCode() {
  const letters = 'ABCDEFGHIJKLMNPQRSTUVWXYZ';
  const numbers = '0123456789';
  const allChars = letters + numbers;

  final random = Random();

  final codeChars = <String>[
    letters[random.nextInt(letters.length)],
    numbers[random.nextInt(numbers.length)],
  ];

  for (int i = 0; i < 4; i++) {
    codeChars.add(allChars[random.nextInt(allChars.length)]);
  }

  codeChars.shuffle(random);

  return codeChars.join();
}

