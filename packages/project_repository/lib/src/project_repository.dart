import 'dart:convert';

import 'package:file_system_client/file_system_client.dart';
import 'package:key_value_storage_client/key_value_storage_client.dart';
import 'package:project_repository/project_repository.dart';

/// {@template project_not_found_exception}
/// Thrown when opening a [Project] whose folder no longer exists.
/// {@endtemplate}
class ProjectNotFoundException implements Exception {
  /// {@macro project_not_found_exception}
  const new(this.project);

  /// The project that could not be found.
  final Project project;
}

/// {@template project_repository}
/// Opens projects and keeps track of the most recently opened ones.
/// {@endtemplate}
class ProjectRepository {
  /// {@macro project_repository}
  new({required this._storage, required this._fileSystem});

  final KeyValueStorageClient _storage;
  final FileSystemClient _fileSystem;

  /// Storage key under which recent projects are persisted.
  static const recentProjectsKey = 'recent_projects';

  /// Maximum number of recent projects that are kept.
  static const maxRecentProjects = 10;

  /// Returns the recently opened projects, most recent first.
  ///
  /// Returns an empty list if nothing was stored or the stored data is
  /// unreadable.
  Future<List<Project>> getRecentProjects() async {
    final raw = await _storage.read(recentProjectsKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return [
        for (final json in decoded)
          Project.fromJson(json as Map<String, dynamic>),
      ];
    } on Object {
      return const [];
    }
  }

  /// Asks the user to pick a project folder.
  ///
  /// Returns `null` if the user cancelled.
  Future<Project?> pickProject() async {
    final path = await _fileSystem.pickDirectory();
    return path == null ? null : Project(path: path);
  }

  /// Opens [project], moving it to the top of the recent projects.
  ///
  /// Throws a [ProjectNotFoundException] if the project folder no longer
  /// exists, in which case it is removed from the recent projects.
  Future<void> openProject(Project project) async {
    final recentProjects = (await getRecentProjects())
        .where((recent) => recent != project)
        .toList();

    if (!await _fileSystem.directoryExists(project.path)) {
      await _saveRecentProjects(recentProjects);
      throw ProjectNotFoundException(project);
    }

    await _saveRecentProjects(
      [project, ...recentProjects].take(maxRecentProjects).toList(),
    );
  }

  Future<void> _saveRecentProjects(List<Project> projects) {
    return _storage.write(
      recentProjectsKey,
      jsonEncode([for (final project in projects) project.toJson()]),
    );
  }
}
