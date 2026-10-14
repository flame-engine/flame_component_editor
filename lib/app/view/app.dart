import 'package:flutter/material.dart';

/// {@template app}
/// The root widget of the Flame Component Editor.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flame Component Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const Scaffold(body: Center(child: Text('Flame Component Editor'))),
    );
  }
}
