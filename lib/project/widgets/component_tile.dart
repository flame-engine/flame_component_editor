import 'package:component_repository/component_repository.dart';
import 'package:flutter/material.dart';

/// {@template component_tile}
/// A list entry for a project [Component], with edit and delete actions.
/// {@endtemplate}
class ComponentTile extends StatelessWidget {
  /// {@macro component_tile}
  const new({
    required this.component,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// The component shown by this tile.
  final Component component;

  /// Called when the user wants to edit the component.
  final VoidCallback onEdit;

  /// Called when the user wants to delete the component.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.widgets_outlined),
      title: Text(component.name),
      onTap: onEdit,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
