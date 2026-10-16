import 'package:flame_component_editor/project_settings/project_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';

/// {@template project_settings_dialog}
/// A dialog to edit the settings of a [Project].
/// {@endtemplate}
class ProjectSettingsDialog extends StatelessWidget {
  /// {@macro project_settings_dialog}
  const new({required this.project, super.key});

  /// Shows the settings dialog of [project].
  static Future<void> show(BuildContext context, Project project) {
    return showDialog<void>(
      context: context,
      builder: (_) => ProjectSettingsDialog(project: project),
    );
  }

  /// The project whose settings are edited.
  final Project project;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectSettingsBloc(
        project: project,
        projectRepository: context.read(),
      )..add(const ProjectSettingsRequested()),
      child: const ProjectSettingsView(),
    );
  }
}
