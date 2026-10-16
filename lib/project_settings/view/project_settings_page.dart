import 'package:flutter/material.dart';
import 'package:project_repository/project_repository.dart';

/// {@template project_settings_page}
/// The settings screen of a [Project].
///
/// This is a placeholder until project settings are implemented.
/// {@endtemplate}
class ProjectSettingsPage extends StatelessWidget {
  /// {@macro project_settings_page}
  const new({required this.project, super.key});

  /// Creates a route to the [ProjectSettingsPage] for [project].
  static Route<void> route(Project project) {
    return MaterialPageRoute<void>(
      builder: (_) => ProjectSettingsPage(project: project),
    );
  }

  /// The project whose settings are shown.
  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${project.name} settings')),
      body: const Center(child: Text('Settings coming soon')),
    );
  }
}
