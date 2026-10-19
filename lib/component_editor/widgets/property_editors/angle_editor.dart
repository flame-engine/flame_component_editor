import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_section.dart';
import 'package:flutter/material.dart';

/// {@template angle_editor}
/// Edits a [ComponentAngle], in degrees. Used by every [RotatedComponent]
/// inside another component.
/// {@endtemplate}
class AngleEditor extends StatelessWidget {
  /// {@macro angle_editor}
  const new({required this.value, required this.onChanged, super.key});

  /// The current angle.
  final ComponentAngle value;

  /// Called with the edited angle.
  final ValueChanged<ComponentAngle> onChanged;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Angle',
      children: [
        NumberField(
          label: 'Degrees',
          // Rounded, so that converting the typed degrees to radians and
          // back gives the same number, and the field keeps the user input.
          value: double.parse(value.degrees.toStringAsFixed(6)),
          min: null,
          onChanged: (degrees) =>
              onChanged(ComponentAngle.fromDegrees(degrees)),
        ),
      ],
    );
  }
}
