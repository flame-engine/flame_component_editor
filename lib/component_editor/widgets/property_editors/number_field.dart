import 'package:flutter/material.dart';

/// {@template number_field}
/// A text field that edits a non-negative number.
///
/// The value is committed with [onChanged] when the field is submitted or
/// loses focus. Invalid input is reverted to [value].
/// {@endtemplate}
class NumberField extends StatefulWidget {
  /// {@macro number_field}
  const new({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The field label.
  final String label;

  /// The current value.
  final double value;

  /// Called with the new value when the user commits a valid edit.
  final ValueChanged<double> onChanged;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final _controller = TextEditingController(text: _format(widget.value));
  final _focusNode = FocusNode();
  late double _committed = widget.value;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _committed = widget.value;
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    final value = double.tryParse(_controller.text.trim());
    if (value == null || value < 0) {
      _controller.text = _format(_committed);
      return;
    }
    if (value == _committed) return;
    _committed = value;
    widget.onChanged(value);
  }

  static String _format(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: widget.label, isDense: true),
      onSubmitted: (_) => _commit(),
    );
  }
}
