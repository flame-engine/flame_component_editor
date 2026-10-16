part of 'project_bloc.dart';

/// Base class for [ProjectBloc] events.
sealed class ProjectEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The project components should be (re)loaded.
final class ProjectComponentsRequested extends ProjectEvent {
  /// Creates a [ProjectComponentsRequested] event.
  const new();
}

/// The user asked to create a component called [name].
final class ProjectComponentCreateRequested extends ProjectEvent {
  /// Creates a [ProjectComponentCreateRequested] event.
  const new(this.name);

  /// The name of the component to create.
  final String name;

  @override
  List<Object> get props => [name];
}

/// The user confirmed that [component] should be deleted.
final class ProjectComponentDeleteRequested extends ProjectEvent {
  /// Creates a [ProjectComponentDeleteRequested] event.
  const new(this.component);

  /// The component to delete.
  final Component component;

  @override
  List<Object> get props => [component];
}
