import 'package:flame_component_editor/project/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';

/// {@template project_page}
/// The dashboard of an open [Project], listing its components.
/// {@endtemplate}
class ProjectPage extends StatelessWidget {
  /// {@macro project_page}
  const new({required this.project, super.key});

  /// Creates a route to the [ProjectPage] for [project].
  static Route<void> route(Project project) {
    return MaterialPageRoute<void>(
      builder: (_) => ProjectPage(project: project),
    );
  }

  /// The open project.
  final Project project;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectBloc(
        project: project,
        componentRepository: context.read(),
        projectRepository: context.read(),
      )..add(const ProjectComponentsRequested()),
      child: ProjectView(project: project),
    );
  }
}
