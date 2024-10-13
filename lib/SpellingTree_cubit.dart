import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';

import  'SpellingTree_state.dart';

class SpellingCubit extends Cubit<SpellingState> {
  SpellingCubit() : super(SpellingState.initial());

  void selectLetter(String letter) {
    emit(state.copyWith(currentWord: state.currentWord + letter));
  }

  void clearWord() {
    emit(state.copyWith(currentWord: ''));
  }

  void shuffleLetters() {
    List<String> shuffledLetters = List.from(state.letters);
    shuffledLetters.shuffle(Random());
    emit(state.copyWith(letters: shuffledLetters));
  }

  void checkWord() {
    // Implement dictionary check and scoring logic here
    // For now, just clear the word
    emit(state.copyWith(currentWord: ''));
  }
}