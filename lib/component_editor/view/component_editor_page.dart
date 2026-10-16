import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_component_editor/component_editor/view/component_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';

/// {@template component_editor_page}
/// The editor screen for a [Component] of a [Project].
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
    return BlocProvider(
      create: (context) => ComponentEditorBloc(
        project: project,
        component: component,
        componentRepository: context.read<ComponentRepository>(),
      ),
      child: const ComponentEditorView(),
    );
  }
}
