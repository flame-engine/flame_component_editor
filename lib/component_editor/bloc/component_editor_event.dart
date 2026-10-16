part of 'component_editor_bloc.dart';

/// Base class for [ComponentEditorBloc] events.
sealed class ComponentEditorEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The editor opened: the other components of the project should be
/// loaded, so the names of children can be checked against their classes.
final class ComponentEditorStarted extends ComponentEditorEvent {
  /// Creates a [ComponentEditorStarted] event.
  const new();
}

/// The user selected the node at [path] in the component tree.
final class ComponentEditorNodeSelected extends ComponentEditorEvent {
  /// Creates a [ComponentEditorNodeSelected] event.
  const new(this.path);

  /// The path of the node, see [ComponentTree].
  final List<int> path;

  @override
  List<Object> get props => [path];
}

/// The user added a component of [type] inside the selected node.
final class ComponentEditorChildAdded extends ComponentEditorEvent {
  /// Creates a [ComponentEditorChildAdded] event.
  const new(this.type);

  /// The type of the new component.
  final ComponentType type;

  @override
  List<Object> get props => [type];
}

/// The user removed the node at [path] from the component tree.
///
/// The root cannot be removed.
final class ComponentEditorNodeRemoved extends ComponentEditorEvent {
  /// Creates a [ComponentEditorNodeRemoved] event.
  const new(this.path);

  /// The path of the node, see [ComponentTree].
  final List<int> path;

  @override
  List<Object> get props => [path];
}

/// The user renamed the selected node.
///
/// The root can't be renamed, and names rejected by
/// [ComponentTree.validateChildName] are ignored.
final class ComponentEditorNameChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorNameChanged] event.
  const new(this.name);

  /// The new name.
  final String name;

  @override
  List<Object> get props => [name];
}

/// The user edited the position of the selected [PositionedComponent].
final class ComponentEditorPositionChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorPositionChanged] event.
  const new(this.position);

  /// The new position.
  final ComponentPosition position;

  @override
  List<Object> get props => [position];
}

/// The user edited the size of the selected [SizedComponent].
final class ComponentEditorSizeChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorSizeChanged] event.
  const new(this.size);

  /// The new size.
  final ComponentSize size;

  @override
  List<Object> get props => [size];
}

/// The user edited the paint of the selected [PaintedComponent].
final class ComponentEditorPaintChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorPaintChanged] event.
  const new(this.paint);

  /// The new paint.
  final ComponentPaint paint;

  @override
  List<Object> get props => [paint];
}

/// The user asked to save the component.
final class ComponentEditorSaveRequested extends ComponentEditorEvent {
  /// Creates a [ComponentEditorSaveRequested] event.
  const new();
}
