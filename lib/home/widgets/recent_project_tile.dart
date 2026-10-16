import 'package:flutter/material.dart';
import 'package:project_repository/project_repository.dart';

/// {@template recent_project_tile}
/// A list entry for a recently opened [Project].
/// {@endtemplate}
class RecentProjectTile extends StatelessWidget {
  /// {@macro recent_project_tile}
  const new({required this.project, required this.onTap, super.key});

  /// The project shown by this tile.
  final Project project;

  /// Called when the tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(project.name),
      subtitle: Text(project.path),
      onTap: onTap,
    );
  }
}
