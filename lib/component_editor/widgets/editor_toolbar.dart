import 'package:editor_preferences_repository/editor_preferences_repository.dart';
import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_component_editor/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template editor_toolbar}
/// The bar above the preview, with the preview options: the selection
/// highlight and the zoom.
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
            const Spacer(),
            const _EditorZoomControls(),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _EditorZoomControls extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final zoom = context.select<ComponentEditorBloc, double>(
      (bloc) => bloc.state.zoom,
    );
    final bloc = context.read<ComponentEditorBloc>();
    return ZoomControls(
      zoom: zoom,
      onZoomOut: ZoomLevels.previous(zoom) == null
          ? null
          : () => bloc.add(const ComponentEditorZoomedOut()),
      onZoomIn: ZoomLevels.next(zoom) == null
          ? null
          : () => bloc.add(const ComponentEditorZoomedIn()),
      onReset: () => bloc.add(const ComponentEditorZoomReset()),
    );
  }
}
