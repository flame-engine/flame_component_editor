import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_section.dart';
import 'package:flame_component_editor/vertices_editor/vertices_editor.dart';
import 'package:flutter/material.dart';

/// {@template vertices_editor}
/// Edits a [ComponentVertices] in a [VerticesEditorDialog]. Used by every
/// [VerticesComponent].
/// {@endtemplate}
class VerticesEditor extends StatelessWidget {
  /// {@macro vertices_editor}
  const new({
    required this.value,
    required this.onChanged,
    this.paint = const ComponentPaint(),
    super.key,
  });

  /// The current vertices.
  final ComponentVertices value;

  /// The paint the dialog draws the polygon with.
  final ComponentPaint paint;

  /// Called with the edited vertices.
  final ValueChanged<ComponentVertices> onChanged;

  Future<void> _edit(BuildContext context) async {
    final vertices = await VerticesEditorDialog.show(
      context,
      vertices: value,
      paint: paint,
    );
    if (vertices != null && vertices != value) onChanged(vertices);
  }

  @override
  Widget build(BuildContext context) {
    final bounds = value.bounds;
    return PropertySection(
      title: 'Vertices',
      children: [
        Text(
          '${value.vertices.length} vertices, '
          '${_number(bounds.width)} × ${_number(bounds.height)}',
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit vertices'),
          onPressed: () => _edit(context),
        ),
      ],
    );
  }

  static String _number(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
