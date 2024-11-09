import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';
import 'package:all_english_words/all_english_words.dart';
import 'package:flutter/material.dart';

class SpellingCubit extends Cubit<SpellingState> {
  final AllEnglishWords _englishWords = AllEnglishWords();

  SpellingCubit() : super(SpellingState.initial()) {
    _initializeGame();
  }


  Future<void> _initializeGame() async {
    final word = await _findRandomWordWith7UniqueAlphabets();
    List<String> letters = word.split('').toSet().toList();

    letters.shuffle(Random());
    final validWords = await getValidWords(letters);
    int maxScore = validWords.fold(0, (sum, word) => sum + calculateWordScore(word));
    print("Max score: $maxScore");
    // Set thresholds
    final thresholds = [
      0,
      (maxScore * 0.02).round(),
      (maxScore * 0.05).round(),
      (maxScore * 0.08).round(),
      (maxScore * 0.11).round(),
      (maxScore * 0.15).round(),
    ];

    print("Letters: $letters");
    print("Valid words: $validWords");
    emit(state.copyWith(letters: letters, validWords: validWords, thresholds: thresholds));
  }

  Future<String> _findRandomWordWith7UniqueAlphabets() async {
    final random = Random();
    String word;
    final allWords = await _englishWords.allWords;
    do {
      word = allWords[random.nextInt(allWords.length)].toLowerCase();
    } while (word.contains('-') || word.length < 7 || word.split('').toSet().length != 7);
    return word;
  }

  void selectLetter(String letter) {
    emit(state.copyWith(currentWord: state.currentWord + letter));
  }

  void clearWord() {

    emit(state.copyWith(message: '', currentWord: ''));
  }


  void backspaceWord() {
    if (state.currentWord.isNotEmpty) {
      final updatedWord = state.currentWord.substring(0, state.currentWord.length - 1);
      emit(state.copyWith(currentWord: updatedWord));
    }
  }
  void shuffleLetters() {
    List<String> firstSixLetters = state.letters.sublist(0, 6);
    firstSixLetters.shuffle(Random());
    List<String> shuffledLetters = [...firstSixLetters, state.letters.last];
    emit(state.copyWith(letters: shuffledLetters));
  }

  void checkWord() {

    final centerLetter = state.letters.last; // Assuming the center letter is at index 6
    final isValidWord = state.validWords.contains(state.currentWord.toLowerCase());
    final usesCenterLetter = state.currentWord.toLowerCase().contains(centerLetter);

    if (state.currentWord.isEmpty) {
      emit(state.copyWith(message: 'Enter a word'));
    } else if (state.currentWord.length < 4) {
      emit(state.copyWith(message: 'Word must be at least 4 letters'));
    } else if (!usesCenterLetter) {
      emit(state.copyWith(message: 'Word must use the center letter $centerLetter'));
    } else if (!isValidWord) {
      emit(state.copyWith(message: 'Invalid word'));
    } else if (state.foundWords.contains(state.currentWord)) {
      emit(state.copyWith(message: 'Word already entered'));
    } else {
      final newScore = state.score + calculateWordScore(state.currentWord);
      final newLevel = calculateLevel(newScore);
      emit(state.copyWith(
        foundWords: List.from(state.foundWords)..add(state.currentWord),
        currentWord: '',
        score: newScore,
        level: newLevel,
        nextLevelThreshold: newLevel < 6 ? state.thresholds[newLevel] : 0,
        message: '',
      ));
    }
  }

  int calculateWordScore(String word) {
    int score = word.length == 4 ? 1 : word.length;
    if (word.split('').toSet().length == 7) { // Check if the word is a pangram
      score += 7;
    }
    return score;
  }

  int calculateLevel(int score) {

    print("Score: $score");
    if(score >= state.thresholds.last){
      int level = state.thresholds.length -1 ;
      print("Level: $level");

      return level;
    }
    int level = state.thresholds.indexWhere((threshold) => score < threshold) - 1;
    print("Level: $level");
    return level;
  }

  Future<List<String>> getValidWords(List<String> letters) async {
    final centerLetter = letters[6];
    final allWords = await _englishWords.allWords;
    final List<String> validWords = allWords.where((word) {
      return word.length >= 4 && word.contains(centerLetter) && word.split('').toSet().every((char) => letters.contains(char));
    }).toList();
    return validWords;
  }

  void showAnswers(BuildContext context) {
    final remainingWords = state.validWords.where((word) => !state.foundWords.contains(word)).toList();
    // emit(state.copyWith(message: 'Words you missed:'));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Words Missed'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (int i = 0; i < (remainingWords.length / 5).ceil(); i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int j = 0; j < 5; j++)
                        if (i * 5 + j < remainingWords.length) ...[
                          Expanded(
                            child: Text(remainingWords[i * 5 + j]),
                          ),
                          if (j < 4) SizedBox(width: 10), // Add spacing between columns
                        ],
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// In SpellingState class

class SpellingState extends Equatable {
  final List<String> letters;
  final String currentWord;
  final int score;
  final List<String> validWords;
  final List<String> foundWords;
  final String message;
  final int level;
  final int nextLevelThreshold;
  final List<int> thresholds;

  SpellingState({
    required this.letters,
    required this.currentWord,
    required this.score,
    required this.validWords,
    required this.foundWords,
    required this.message,
    required this.level,
    required this.nextLevelThreshold,
    required this.thresholds,
  });

  factory SpellingState.initial() {
    return SpellingState(
      letters: [],
      currentWord: '',
      score: 0,
      validWords: [],
      foundWords: [],
      message: '',
      level: 0,
      nextLevelThreshold: 10,
      thresholds: [0, 10, 15, 20, 25, 30],
    );
  }

  SpellingState copyWith({
    List<String>? letters,
    String? currentWord,
    int? score,
    List<String>? validWords,
    List<String>? foundWords,
    String? message,
    int? level,
    int? nextLevelThreshold,
    List<int>? thresholds,
  }) {
    return SpellingState(
      letters: letters ?? this.letters,
      currentWord: currentWord ?? this.currentWord,
      score: score ?? this.score,
      validWords: validWords ?? this.validWords,
      foundWords: foundWords ?? this.foundWords,
      message: message ?? this.message,
      level: level ?? this.level,
      nextLevelThreshold: nextLevelThreshold ?? this.nextLevelThreshold,
      thresholds: thresholds ?? this.thresholds,
    );
  }

  @override
  List<Object> get props => [letters, currentWord, score, validWords, foundWords, message, level, nextLevelThreshold, thresholds];
}