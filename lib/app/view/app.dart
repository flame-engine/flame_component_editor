import 'package:component_repository/component_repository.dart';
import 'package:editor_preferences_repository/editor_preferences_repository.dart';
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
    required this.editorPreferencesRepository,
    super.key,
  });

  /// The repository used to open projects.
  final ProjectRepository projectRepository;

  /// The repository used to manage the components of a project.
  final ComponentRepository componentRepository;

  /// The repository used to keep the editor preferences.
  final EditorPreferencesRepository editorPreferencesRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: projectRepository),
        RepositoryProvider.value(value: componentRepository),
        RepositoryProvider.value(value: editorPreferencesRepository),
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
