import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/color_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/enum_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_section.dart';
import 'package:flutter/material.dart';

/// {@template paint_editor}
/// Edits a [ComponentPaint]. Used by every [PaintedComponent].
/// {@endtemplate}
class PaintEditor extends StatelessWidget {
  /// {@macro paint_editor}
  const new({required this.value, required this.onChanged, super.key});

  /// The current paint.
  final ComponentPaint value;

  /// Called with the edited paint.
  final ValueChanged<ComponentPaint> onChanged;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Paint',
      children: [
        ColorField(
          label: 'Color',
          value: value.color,
          onChanged: (color) => onChanged(value.copyWith(color: color)),
        ),
        EnumField<PaintStyle>(
          label: 'Style',
          values: PaintStyle.values,
          value: value.style,
          labelOf: (style) => switch (style) {
            PaintStyle.fill => 'Fill',
            PaintStyle.stroke => 'Stroke',
          },
          onChanged: (style) => onChanged(value.copyWith(style: style)),
        ),
      ],
    );
  }
}
