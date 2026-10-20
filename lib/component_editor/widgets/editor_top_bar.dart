import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_component_editor/palette/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template editor_top_bar}
/// The bar below the app bar, above the editor panels, with the actions
/// that concern the whole project, such as managing its palette.
/// {@endtemplate}
class EditorTopBar extends StatelessWidget {
  /// {@macro editor_top_bar}
  const new({super.key});

  /// Height of the bar.
  static const height = 40.0;

  Future<void> _openPalette(BuildContext context) async {
    final bloc = context.read<ComponentEditorBloc>();
    final palette = await PaletteDialog.show(
      context,
      project: bloc.project,
      component: bloc.state.component,
    );
    // The editor may have been closed meanwhile.
    if (palette != null && context.mounted) {
      bloc.add(ComponentEditorPaletteChanged(palette));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainer,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Palette',
              iconSize: 20,
              color: colorScheme.onSurfaceVariant,
              icon: const Icon(Icons.palette_outlined),
              onPressed: () => _openPalette(context),
            ),
          ],
        ),
      ),
    );
  }
}
