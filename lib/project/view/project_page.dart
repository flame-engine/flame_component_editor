import 'package:flutter/material.dart';
import 'package:project_repository/project_repository.dart';

/// {@template project_page}
/// The editor screen for an open [Project].
///
/// This is a placeholder until the project editor is implemented.
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
    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(project.path),
            const SizedBox(height: 8),
            const Text('Project editor coming soon'),
          ],
        ),
      ),
    );
  }
}
