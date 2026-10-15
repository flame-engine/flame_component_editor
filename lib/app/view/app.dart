import 'package:flame_component_editor/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';

/// {@template app}
/// The root widget of the Flame Component Editor.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const new({required this.projectRepository, super.key});

  /// The repository used to open projects.
  final ProjectRepository projectRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: projectRepository,
      child: MaterialApp(
        title: 'Flame Component Editor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const HomePage(),
      ),
    );
  }
}
