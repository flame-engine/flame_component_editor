import 'package:flame/game.dart';
import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_component_editor/component_editor/widgets/preview/preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template component_preview}
/// Renders the component being edited with Flame.
/// {@endtemplate}
class ComponentPreview extends StatefulWidget {
  /// {@macro component_preview}
  const new({super.key});

  @override
  State<ComponentPreview> createState() => _ComponentPreviewState();
}

class _ComponentPreviewState extends State<ComponentPreview> {
  late final _game = ComponentPreviewGame(
    component: context.read<ComponentEditorBloc>().state.component,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComponentEditorBloc, ComponentEditorState>(
      listenWhen: (previous, current) =>
          previous.component != current.component,
      listener: (context, state) => _game.show(state.component),
      // The preview takes no keyboard input; without this the game widget
      // would grab focus and swallow the editor shortcuts (e.g. Cmd+S).
      child: GameWidget(game: _game, autofocus: false),
    );
  }
}
