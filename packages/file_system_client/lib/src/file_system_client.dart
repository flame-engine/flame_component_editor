import 'dart:io';

import 'package:file_selector/file_selector.dart' as file_selector;

/// Signature of a function that opens a native directory picker and returns
/// the selected path, or `null` if the user cancelled.
typedef DirectoryPicker = Future<String?> Function();

/// {@template file_system_client}
/// A client for interacting with the local file system.
/// {@endtemplate}
class FileSystemClient {
  /// {@macro file_system_client}
  new({DirectoryPicker? directoryPicker})
    : _directoryPicker = directoryPicker ?? file_selector.getDirectoryPath;

  final DirectoryPicker _directoryPicker;

  /// Opens a native dialog to pick a directory.
  ///
  /// Returns the selected path, or `null` if the dialog was cancelled.
  Future<String?> pickDirectory() => _directoryPicker();

  /// Whether a directory exists at [path].
  Future<bool> directoryExists(String path) async =>
      Directory(path).existsSync();
}
