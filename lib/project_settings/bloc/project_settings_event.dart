part of 'project_settings_bloc.dart';

/// Base class for [ProjectSettingsBloc] events.
sealed class ProjectSettingsEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The project settings should be loaded.
final class ProjectSettingsRequested extends ProjectSettingsEvent {
  /// Creates a [ProjectSettingsRequested] event.
  const new();
}

/// The user edited the output path.
final class ProjectSettingsOutputPathChanged extends ProjectSettingsEvent {
  /// Creates a [ProjectSettingsOutputPathChanged] event.
  const new(this.outputPath);

  /// The new output path.
  final String outputPath;

  @override
  List<Object> get props => [outputPath];
}

/// The user asked to pick the output path with the folder picker.
final class ProjectSettingsBrowseRequested extends ProjectSettingsEvent {
  /// Creates a [ProjectSettingsBrowseRequested] event.
  const new();
}

/// The user asked to save the settings.
final class ProjectSettingsSubmitted extends ProjectSettingsEvent {
  /// Creates a [ProjectSettingsSubmitted] event.
  const new();
}
