import 'dart:convert';
import 'package:flutter/services.dart';

class WordService {
  static final Map<String, String> _wordToCategory = {};

  static Future<void> init() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/wordslists.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      jsonMap.forEach((category, wordsList) {
        if (wordsList is List) {
          for (var word in wordsList) {
            _wordToCategory[word.toString()] = category;
          }
        }
      });
      print("✅ 단어장 로드 완료! 총 ${_wordToCategory.length}개의 단어");
    } catch (e) {
      print("❌ 단어장 로드 실패: $e");
    }
  }

  static List<String> getRandomWords(int count) {
    List<String> allWords = _wordToCategory.keys.toList();
    allWords.shuffle();
    return allWords.take(count).toList();
  }

  static String getCategoryForWord(String word) {
    return _wordToCategory[word] ?? 'food';
  }
}