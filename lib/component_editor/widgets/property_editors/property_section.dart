import 'package:flutter/material.dart';

/// {@template property_section}
/// A titled group of property fields in the properties panel.
/// {@endtemplate}
class PropertySection extends StatelessWidget {
  /// {@macro property_section}
  const new({required this.title, required this.children, super.key});

  /// The name of the property.
  final String title;

  /// The fields that edit the property.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          ...children,
        ],
      ),
    );
  }
}
