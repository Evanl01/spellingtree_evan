import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexagon/hexagon.dart';
import 'SpellingTree_cubit.dart';
import 'dart:math';

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
      ),
      body: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;

                return Center(
                  child: Container(
                    height: 500, // Set a fixed height for the row
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Center children vertically
                      children: [
                        BlocBuilder<SpellingCubit, SpellingState>(
                          builder: (context, state) {
                            // Update the thresholds list
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add horizontal padding
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Score: ${state.score}', style: TextStyle(fontSize: 18)),
                                  Column(
                                    children: [
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < state.level ? Icons.star : Icons.star_border,
                                            color: Colors.yellow, size: 20,
                                          );
                                        }),
                                      ),
                                      Text(
                                        state.level < 5
                                            ? 'Level ${state.level+1} at ${state.thresholds[state.level+1]} points'
                                            : 'Max level reached',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20), // Add a SizedBox for spacing
                        BlocBuilder<SpellingCubit, SpellingState>(
                          builder: (context, state) {
                            return Center(
                              child: Container(
                                width: 250, // Set a fixed width for the TextField and button
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        readOnly: true,
                                        maxLength: 10, // Limit the length of the TextField
                                        decoration: InputDecoration(
                                          hintText: state.currentWord.toUpperCase(),
                                          counterText: '', // Hide the counter text
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.backspace, size: 15,),
                                      onPressed: () => context.read<SpellingCubit>().backspaceWord(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        BlocBuilder<SpellingCubit, SpellingState>(
                          builder: (context, state) {
                            return Container(
                              height: 20, // Fixed height for the message area
                              child: state.message.isNotEmpty
                                  ? Text(
                                state.message,
                                style: TextStyle(color: Colors.red),
                              )
                                  : Container(),
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
                                    left: maxWidth / 2 + 70 * cos((i * pi / 3) + (pi / 6)) - 40, // Adjusted for centering
                                    top: maxHeight / 2 + 70 * sin((i * pi / 3) + (pi / 6)) - 220, // Adjusted for centering
                                    child: HexagonButton(index: i, isCenter: false),
                                  ),
                                Positioned(
                                  left: maxWidth / 2 - 40, // Adjusted for centering
                                  top: maxHeight / 2 - 220, // Adjusted for centering
                                  child: HexagonButton(index: 6, isCenter: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Found Words',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () => context.read<SpellingCubit>().showAnswers(context),
                      child: Text('Show answers'),
                    ),
                  ],
                ),
                SizedBox(height: 30), // Add a SizedBox for spacing
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: BlocBuilder<SpellingCubit, SpellingState>(
                        builder: (context, state) {
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Number of columns
                              crossAxisSpacing: 10, // Spacing between columns
                              mainAxisSpacing: 10, // Spacing between rows
                            ),
                            itemCount: state.foundWords.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(state.foundWords[index]),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
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
          onTap: () => context.read<SpellingCubit>().selectLetter(state.letters[index].toUpperCase()),
          child: HexagonWidget.flat(
            width: 80,
            color: isCenter ? Colors.grey : Colors.blue,
            cornerRadius: 8.0,
            child: Center(
              child: Text(
                state.letters[index].toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }
}