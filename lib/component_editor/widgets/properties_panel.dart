import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_editors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template properties_panel}
/// Lists an editor for every property of the node selected in the
/// component tree.
///
/// Editors are picked from the capabilities the node implements, so a new
/// component type gets them without changes here. The position is only
/// edited on children: the root is placed by whoever uses it.
/// {@endtemplate}
class PropertiesPanel extends StatelessWidget {
  /// {@macro properties_panel}
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final (component, selectedPath) = context
        .select<ComponentEditorBloc, (Component, List<int>)>(
          (bloc) => (bloc.state.selectedNode, bloc.state.selectedPath),
        );
    final bloc = context.read<ComponentEditorBloc>();
    final isRoot = selectedPath.isEmpty;

    return ListView(
      // Fresh fields for every node, so edits never leak between nodes.
      key: ValueKey(selectedPath.join('.')),
      children: [
        if (component case final PositionedComponent positioned when !isRoot)
          PositionEditor(
            value: positioned.position,
            onChanged: (position) =>
                bloc.add(ComponentEditorPositionChanged(position)),
          ),
        if (component case final SizedComponent sized)
          SizeEditor(
            value: sized.size,
            onChanged: (size) => bloc.add(ComponentEditorSizeChanged(size)),
          ),
        if (component case final PaintedComponent painted)
          PaintEditor(
            value: painted.paint,
            onChanged: (paint) => bloc.add(ComponentEditorPaintChanged(paint)),
          ),
      ],
    );
  }
}
