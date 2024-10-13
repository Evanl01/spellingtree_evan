import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexagon/hexagon.dart';
import 'dart:math';
import 'SpellingTree_cubit.dart';
import 'SpellingTree_state.dart';

void main() {
  runApp(SpellingTreeApp());
}

class SpellingTreeApp extends StatelessWidget {
  const SpellingTreeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => SpellingCubit(),
        child: SpellingTreeScreen(),
      ),
    );
  }
}

class SpellingTreeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spelling Tree'),
        actions: [
          BlocBuilder<SpellingCubit, SpellingState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text('Score: ${state.score}')),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final centerX = constraints.maxWidth / 2;
          final centerY = constraints.maxHeight / 2 - 50; // Adjusted for buttons

          return Column(
            children: [
              BlocBuilder<SpellingCubit, SpellingState>(
                builder: (context, state) {
                  return Center(
                    child: Container(
                      width: 200, // Set a fixed width for the TextField
                      child: TextField(
                        readOnly: true,
                        maxLength: 10, // Limit the length of the TextField
                        decoration: InputDecoration(
                          hintText: state.currentWord,
                          counterText: '', // Hide the counter text
                        ),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 0; i < 6; i++)
                        Positioned(
                          left: centerX + 90 * cos((i * pi / 3) + (pi / 6)) - 60, // Adjusted for centering
                          top: centerY + 90 * sin((i * pi / 3) + (pi / 6)) -100, // Adjusted for centering
                          child: HexagonButton(index: i, isCenter: false),
                        ),
                      Positioned(
                        left: centerX - 60, // Adjusted for centering
                        top: centerY - 100, // Adjusted for centering
                        child: HexagonButton(index: 6, isCenter: true),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 100.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.read<SpellingCubit>().checkWord(),
                      child: Text('Check'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.read<SpellingCubit>().shuffleLetters(),
                      child: Text('Shuffle'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.read<SpellingCubit>().clearWord(),
                      child: Text('Clear'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HexagonButton extends StatelessWidget {
  final int index;
  final bool isCenter;

  HexagonButton({required this.index, required this.isCenter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpellingCubit, SpellingState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => context.read<SpellingCubit>().selectLetter(state.letters[index]),
          child: HexagonWidget.flat(
            width: 70,
            color: isCenter ? Colors.grey : Colors.blue,
            cornerRadius: 8.0,
            child: Center(
              child: Text(
                state.letters[index],
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }
}