import 'package:flutter/material.dart';

/// {@template enum_field}
/// Picks one of [values] with a segmented button.
/// {@endtemplate}
class EnumField<T extends Enum> extends StatelessWidget {
  /// {@macro enum_field}
  const new({
    required this.label,
    required this.values,
    required this.value,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  /// The field label.
  final String label;

  /// The values to choose from.
  final List<T> values;

  /// The selected value.
  final T value;

  /// Returns the text shown for a value.
  final String Function(T value) labelOf;

  /// Called with the value the user picked.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        SegmentedButton<T>(
          showSelectedIcon: false,
          segments: [
            for (final value in values)
              ButtonSegment(value: value, label: Text(labelOf(value))),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.single),
        ),
      ],
    );
  }
}
