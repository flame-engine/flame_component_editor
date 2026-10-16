part of 'component_editor_bloc.dart';

/// Base class for [ComponentEditorBloc] events.
sealed class ComponentEditorEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The user edited the size of a [SizedComponent].
final class ComponentEditorSizeChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorSizeChanged] event.
  const new(this.size);

  /// The new size.
  final ComponentSize size;

  @override
  List<Object> get props => [size];
}

/// The user edited the paint of a [PaintedComponent].
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
