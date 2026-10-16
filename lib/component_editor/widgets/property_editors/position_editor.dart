import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_section.dart';
import 'package:flutter/material.dart';

/// {@template position_editor}
/// Edits a [ComponentPosition]. Used by every [PositionedComponent] inside
/// another component.
/// {@endtemplate}
class PositionEditor extends StatelessWidget {
  /// {@macro position_editor}
  const new({required this.value, required this.onChanged, super.key});

  /// The current position.
  final ComponentPosition value;

  /// Called with the edited position.
  final ValueChanged<ComponentPosition> onChanged;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Position',
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: NumberField(
                label: 'X',
                value: value.x,
                min: null,
                onChanged: (x) => onChanged(value.copyWith(x: x)),
              ),
            ),
            Expanded(
              child: NumberField(
                label: 'Y',
                value: value.y,
                min: null,
                onChanged: (y) => onChanged(value.copyWith(y: y)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
