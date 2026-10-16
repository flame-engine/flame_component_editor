part of 'project_settings_bloc.dart';

/// The status of the [ProjectSettingsBloc].
enum ProjectSettingsStatus {
  /// Nothing has been loaded yet.
  initial,

  /// The settings are being loaded.
  loading,

  /// The settings are loaded and can be edited.
  ready,

  /// The settings are being saved.
  saving,

  /// The settings were saved.
  saved,

  /// The output path is not a folder inside the project.
  invalidOutputPath,

  /// Something went wrong.
  failure,
}

/// {@template project_settings_state}
/// The state of the [ProjectSettingsBloc].
/// {@endtemplate}
final class ProjectSettingsState extends Equatable {
  /// {@macro project_settings_state}
  const new({
    this.status = ProjectSettingsStatus.initial,
    this.outputPath = ProjectSettings.defaultOutputPath,
  });

  /// The current status.
  final ProjectSettingsStatus status;

  /// Folder, relative to the project folder, where the generated Dart source
  /// code is written.
  final String outputPath;

  /// Returns a copy of this state with the given fields replaced.
  ProjectSettingsState copyWith({
    ProjectSettingsStatus? status,
    String? outputPath,
  }) {
    return ProjectSettingsState(
      status: status ?? this.status,
      outputPath: outputPath ?? this.outputPath,
    );
  }

  @override
  List<Object> get props => [status, outputPath];
}
