import 'package:equatable/equatable.dart';

class SpellingState extends Equatable {
  final List<String> letters;
  final String currentWord;
  final int score;

  SpellingState({required this.letters, required this.currentWord, required this.score});

  factory SpellingState.initial() {
    return SpellingState(
      letters: ['A', 'B', 'C', 'D', 'E', 'F', 'G'], // Example letters
      currentWord: '',
      score: 0,
    );
  }

  SpellingState copyWith({List<String>? letters, String? currentWord, int? score}) {
    return SpellingState(
      letters: letters ?? this.letters,
      currentWord: currentWord ?? this.currentWord,
      score: score ?? this.score,
    );
  }

  @override
  List<Object> get props => [letters, currentWord, score];
}