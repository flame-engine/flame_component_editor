import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_section.dart';
import 'package:flutter/material.dart';

/// {@template radius_editor}
/// Edits a [ComponentRadius]. Used by every [RadiusComponent].
/// {@endtemplate}
class RadiusEditor extends StatelessWidget {
  /// {@macro radius_editor}
  const new({required this.value, required this.onChanged, super.key});

  /// The current radius.
  final ComponentRadius value;

  /// Called with the edited radius.
  final ValueChanged<ComponentRadius> onChanged;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Radius',
      children: [
        NumberField(
          label: 'Radius',
          value: value.radius,
          onChanged: (radius) => onChanged(value.copyWith(radius: radius)),
        ),
      ],
    );
  }
}
