import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/palette/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_repository/project_repository.dart';

/// {@template palette_dialog}
/// A dialog to manage the [Palette] of a [Project].
/// {@endtemplate}
class PaletteDialog extends StatelessWidget {
  /// {@macro palette_dialog}
  const new({required this.project, required this.component, super.key});

  /// Shows the palette dialog of [project], opened while editing
  /// [component], whose unsaved palette colors count as used.
  ///
  /// Returns the saved palette, or `null` if it was not saved.
  static Future<Palette?> show(
    BuildContext context, {
    required Project project,
    required Component component,
  }) {
    return showDialog<Palette>(
      context: context,
      builder: (_) => PaletteDialog(project: project, component: component),
    );
  }

  /// The project whose palette is edited.
  final Project project;

  /// The component being edited.
  final Component component;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaletteBloc(
        project: project,
        editedComponent: component,
        componentRepository: context.read(),
        projectRepository: context.read(),
      )..add(const PaletteStarted()),
      child: const PaletteView(),
    );
  }
}
