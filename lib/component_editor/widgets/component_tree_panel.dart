import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template component_tree_panel}
/// Shows the component being edited and the components inside it as a
/// tree.
///
/// Tapping a node selects it, so the properties panel edits it. New
/// components are added inside the selected node.
/// {@endtemplate}
class ComponentTreePanel extends StatelessWidget {
  /// {@macro component_tree_panel}
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final (component, selectedPath) = context
        .select<ComponentEditorBloc, (Component, List<int>)>(
          (bloc) => (bloc.state.component, bloc.state.selectedPath),
        );
    final bloc = context.read<ComponentEditorBloc>();
    final nodes = _flatten(component, const []).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Components',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              PopupMenuButton<ComponentType>(
                tooltip: 'Add child',
                icon: const Icon(Icons.add),
                onSelected: (type) => bloc.add(ComponentEditorChildAdded(type)),
                itemBuilder: (_) => [
                  for (final type in ComponentType.values)
                    PopupMenuItem(
                      value: type,
                      child: ListTile(
                        leading: Icon(iconFor(type)),
                        title: Text(type.label),
                      ),
                    ),
                ],
              ),
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: selectedPath.isEmpty
                    ? null
                    : () => bloc.add(ComponentEditorNodeRemoved(selectedPath)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              for (final (path, node) in nodes)
                ListTile(
                  key: ValueKey(path.join('.')),
                  dense: true,
                  selected: listEquals(path, selectedPath),
                  contentPadding: EdgeInsetsDirectional.only(
                    start: 16.0 + path.length * 16,
                    end: 16,
                  ),
                  leading: Icon(iconFor(node.type), size: 18),
                  title: Text(node.name),
                  onTap: () => bloc.add(ComponentEditorNodeSelected(path)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// The icon shown for components of [type].
  static IconData iconFor(ComponentType type) {
    return switch (type) {
      ComponentType.rectangle => Icons.crop_square,
    };
  }

  static Iterable<(List<int>, Component)> _flatten(
    Component node,
    List<int> path,
  ) sync* {
    yield (path, node);
    for (final (index, child) in node.children.indexed) {
      yield* _flatten(child, [...path, index]);
    }
  }
}
