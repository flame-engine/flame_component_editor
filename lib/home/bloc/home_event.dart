part of 'home_bloc.dart';

/// Base class for [HomeBloc] events.
sealed class HomeEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The recent projects should be (re)loaded.
final class HomeRecentProjectsRequested extends HomeEvent {
  /// Creates a [HomeRecentProjectsRequested] event.
  const new();
}

/// The user asked to pick a project folder to open.
final class HomeOpenProjectRequested extends HomeEvent {
  /// Creates a [HomeOpenProjectRequested] event.
  const new();
}

/// The user selected one of the recent projects.
final class HomeRecentProjectSelected extends HomeEvent {
  /// Creates a [HomeRecentProjectSelected] event.
  const new(this.project);

  /// The selected project.
  final Project project;

  @override
  List<Object> get props => [project];
}
