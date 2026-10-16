import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

/// {@template color_field}
/// Shows a color swatch and its hex code; tapping it opens a color picker.
///
/// Colors are 32 bit ARGB values.
/// {@endtemplate}
class ColorField extends StatelessWidget {
  /// {@macro color_field}
  const new({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The field label.
  final String label;

  /// The current color, as a 32 bit ARGB value.
  final int value;

  /// Called with the color the user picked.
  final ValueChanged<int> onChanged;

  Future<void> _pick(BuildContext context) async {
    final color = await showColorPickerDialog(
      context,
      Color(value),
      title: Text(label),
      pickersEnabled: const {
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.wheel: true,
      },
      enableOpacity: true,
      showColorCode: true,
      colorCodeHasColor: true,
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 320),
    );
    final picked = color.toARGB32();
    if (picked != value) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hex = value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, isDense: true),
        child: Row(
          spacing: 8,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Color(value),
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text('#$hex'),
          ],
        ),
      ),
    );
  }
}
