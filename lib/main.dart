import 'package:file_system_client/file_system_client.dart';
import 'package:flame_component_editor/app/app.dart';
import 'package:flutter/widgets.dart';
import 'package:key_value_storage_client/key_value_storage_client.dart';
import 'package:project_repository/project_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final projectRepository = ProjectRepository(
    storage: KeyValueStorageClient(),
    fileSystem: FileSystemClient(),
  );

  runApp(App(projectRepository: projectRepository));
}
