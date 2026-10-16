import 'package:component_repository/component_repository.dart';
import 'package:flutter/material.dart';
import 'package:project_repository/project_repository.dart';

/// {@template component_editor_page}
/// The editor screen for a [Component] of a [Project].
///
/// This is a placeholder until the component editor is implemented.
/// {@endtemplate}
class ComponentEditorPage extends StatelessWidget {
  /// {@macro component_editor_page}
  const new({required this.project, required this.component, super.key});

  /// Creates a route to the [ComponentEditorPage] for [component].
  static Route<void> route(Project project, Component component) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          ComponentEditorPage(project: project, component: component),
    );
  }

  /// The project the component belongs to.
  final Project project;

  /// The component being edited.
  final Component component;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(component.name)),
      body: const Center(child: Text('Component editor coming soon')),
    );
  }
}
