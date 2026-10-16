import 'package:component_repository/component_repository.dart';
import 'package:file_system_client/file_system_client.dart';
import 'package:flame_component_editor/app/app.dart';
import 'package:flutter/widgets.dart';
import 'package:key_value_storage_client/key_value_storage_client.dart';
import 'package:project_repository/project_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final fileSystem = FileSystemClient();

  final projectRepository = ProjectRepository(
    storage: KeyValueStorageClient(),
    fileSystem: fileSystem,
  );
  final componentRepository = ComponentRepository(fileSystem: fileSystem);

  runApp(
    App(
      projectRepository: projectRepository,
      componentRepository: componentRepository,
    ),
  );
}
