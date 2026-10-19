import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/vertices_editor/bloc/vertices_editor_cubit.dart';
import 'package:flame_component_editor/vertices_editor/view/vertices_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template vertices_editor_dialog}
/// A dialog to edit the vertices of a polygon on a canvas.
/// {@endtemplate}
class VerticesEditorDialog extends StatelessWidget {
  /// {@macro vertices_editor_dialog}
  const new({required this.vertices, required this.paint, super.key});

  /// Shows the dialog editing [vertices], drawn with [paint], and returns
  /// the applied vertices, or `null` if the user cancelled.
  static Future<ComponentVertices?> show(
    BuildContext context, {
    required ComponentVertices vertices,
    required ComponentPaint paint,
  }) {
    return showDialog<ComponentVertices>(
      context: context,
      builder: (_) => VerticesEditorDialog(vertices: vertices, paint: paint),
    );
  }

  /// The vertices the dialog opens with.
  final ComponentVertices vertices;

  /// The paint the polygon is drawn with.
  final ComponentPaint paint;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerticesEditorCubit(vertices),
      child: VerticesEditorView(paint: paint),
    );
  }
}
