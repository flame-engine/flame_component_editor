import 'dart:convert';

import 'package:component_repository/component_repository.dart';
import 'package:file_system_client/file_system_client.dart';
import 'package:path/path.dart' as p;

/// {@template invalid_component_name_exception}
/// Thrown when creating a [Component] with a name that is not a valid
/// identifier.
/// {@endtemplate}
class InvalidComponentNameException implements Exception {
  /// {@macro invalid_component_name_exception}
  const new(this.name);

  /// The rejected name.
  final String name;
}

/// {@template component_already_exists_exception}
/// Thrown when creating a [Component] whose name is already taken.
/// {@endtemplate}
class ComponentAlreadyExistsException implements Exception {
  /// {@macro component_already_exists_exception}
  const new(this.name);

  /// The name that is already taken.
  final String name;
}

/// {@template component_repository}
/// Lists, creates and deletes the components of a project.
///
/// Each component is stored as `<name>.json` inside the
/// [componentsDirectory] of the project folder.
/// {@endtemplate}
class ComponentRepository {
  /// {@macro component_repository}
  new({required this._fileSystem});

  final FileSystemClient _fileSystem;

  /// Folder, relative to the project folder, where components are stored.
  static const componentsDirectory = '.flame_editor/components';

  static final _validName = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  /// Returns the components of the project at [projectPath], sorted by name.
  ///
  /// Component files that cannot be read are skipped.
  Future<List<Component>> getComponents(String projectPath) async {
    final files = await _fileSystem.listFiles(
      _directory(projectPath),
      extension: '.json',
    );

    final components = <Component>[];
    for (final file in files) {
      try {
        final json = jsonDecode(await _fileSystem.readFile(file));
        components.add(Component.fromJson(json as Map<String, dynamic>));
      } on Object {
        continue;
      }
    }
    return components..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Creates a component called [name] in the project at [projectPath].
  ///
  /// Throws an [InvalidComponentNameException] if [name] is not a valid
  /// identifier, or a [ComponentAlreadyExistsException] if a component with
  /// that name already exists.
  Future<Component> createComponent(String projectPath, String name) async {
    if (!_validName.hasMatch(name)) {
      throw InvalidComponentNameException(name);
    }

    final path = _file(projectPath, name);
    if (await _fileSystem.fileExists(path)) {
      throw ComponentAlreadyExistsException(name);
    }

    final component = Component(name: name);
    await _fileSystem.writeFile(path, jsonEncode(component.toJson()));
    return component;
  }

  /// Deletes [component] from the project at [projectPath].
  Future<void> deleteComponent(String projectPath, Component component) {
    return _fileSystem.deleteFile(_file(projectPath, component.name));
  }

  String _directory(String projectPath) =>
      p.join(projectPath, componentsDirectory);

  String _file(String projectPath, String name) =>
      p.join(_directory(projectPath), '$name.json');
}
