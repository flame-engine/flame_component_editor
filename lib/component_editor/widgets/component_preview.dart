import 'package:flame/game.dart';
import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_component_editor/component_editor/widgets/preview/preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template component_preview}
/// Renders the component being edited with Flame, highlighting the
/// selected node unless [ComponentEditorState.isSelectionHighlighted] is
/// off.
/// {@endtemplate}
class ComponentPreview extends StatefulWidget {
  /// {@macro component_preview}
  const new({super.key});

  @override
  State<ComponentPreview> createState() => _ComponentPreviewState();
}

class _ComponentPreviewState extends State<ComponentPreview> {
  late final ComponentPreviewGame _game = _createGame(
    context.read<ComponentEditorBloc>().state,
  );

  static ComponentPreviewGame _createGame(ComponentEditorState state) {
    return ComponentPreviewGame(
      component: state.component,
      highlightedPath: _highlightedPath(state),
    );
  }

  static List<int>? _highlightedPath(ComponentEditorState state) =>
      state.isSelectionHighlighted ? state.selectedPath : null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComponentEditorBloc, ComponentEditorState>(
      listenWhen: (previous, current) =>
          previous.component != current.component ||
          previous.selectedPath != current.selectedPath ||
          previous.isSelectionHighlighted != current.isSelectionHighlighted,
      // A single call, so a removed node and the new selection are shown
      // together.
      listener: (context, state) =>
          _game.show(state.component, highlightedPath: _highlightedPath(state)),
      // The preview takes no keyboard input; without this the game widget
      // would grab focus and swallow the editor shortcuts (e.g. Cmd+S).
      child: GameWidget(game: _game, autofocus: false),
    );
  }
}
