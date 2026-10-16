import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_section.dart';
import 'package:flutter/material.dart';

/// {@template size_editor}
/// Edits a [ComponentSize]. Used by every [SizedComponent].
/// {@endtemplate}
class SizeEditor extends StatelessWidget {
  /// {@macro size_editor}
  const new({required this.value, required this.onChanged, super.key});

  /// The current size.
  final ComponentSize value;

  /// Called with the edited size.
  final ValueChanged<ComponentSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Size',
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: NumberField(
                label: 'Width',
                value: value.width,
                onChanged: (width) => onChanged(value.copyWith(width: width)),
              ),
            ),
            Expanded(
              child: NumberField(
                label: 'Height',
                value: value.height,
                onChanged: (height) =>
                    onChanged(value.copyWith(height: height)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
