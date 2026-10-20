import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/color_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/enum_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_section.dart';
import 'package:flutter/material.dart';

/// {@template paint_editor}
/// Edits a [ComponentPaint]. Used by every [PaintedComponent].
///
/// Its color is picked by hand or from the [palette].
/// {@endtemplate}
class PaintEditor extends StatelessWidget {
  /// {@macro paint_editor}
  const new({
    required this.value,
    required this.onChanged,
    this.palette = const Palette(),
    super.key,
  });

  /// The current paint.
  final ComponentPaint value;

  /// The palette of the project.
  final Palette palette;

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
          palette: palette,
          paletteColor: value.paletteColor,
          onChanged: (color) => onChanged(value.withColor(color)),
          onPaletteColorSelected: (name) => onChanged(
            value.withPaletteColor(name, palette.colorOf(name) ?? value.color),
          ),
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
