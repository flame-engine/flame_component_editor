import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template editor_toolbar}
/// The bar above the preview, with the preview options.
/// {@endtemplate}
class EditorToolbar extends StatelessWidget {
  /// {@macro editor_toolbar}
  const new({super.key});

  /// Height of the toolbar.
  static const height = 40.0;

  @override
  Widget build(BuildContext context) {
    final isSelectionHighlighted = context.select<ComponentEditorBloc, bool>(
      (bloc) => bloc.state.isSelectionHighlighted,
    );
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainer,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Highlight selection',
              iconSize: 20,
              isSelected: isSelectionHighlighted,
              icon: const Icon(Icons.highlight_alt),
              // Selected toggles get a filled background, so it's clear at
              // a glance whether the highlight is on.
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colorScheme.primaryContainer
                      : null,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              onPressed: () => context.read<ComponentEditorBloc>().add(
                const ComponentEditorSelectionHighlightToggled(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
