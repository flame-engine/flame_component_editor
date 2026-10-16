import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';

/// {@template app}
/// The root widget of the Flame Component Editor.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const new({
    required this.projectRepository,
    required this.componentRepository,
    super.key,
  });

  /// The repository used to open projects.
  final ProjectRepository projectRepository;

  /// The repository used to manage the components of a project.
  final ComponentRepository componentRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: projectRepository),
        RepositoryProvider.value(value: componentRepository),
      ],
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
