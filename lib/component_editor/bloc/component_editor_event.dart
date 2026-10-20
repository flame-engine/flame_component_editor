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
///
/// Polygons start with the vertices of [polygonShape].
final class ComponentEditorChildAdded extends ComponentEditorEvent {
  /// Creates a [ComponentEditorChildAdded] event.
  const new(this.type, {this.polygonShape = PolygonShape.triangle});

  /// The type of the new component.
  final ComponentType type;

  /// The shape of the new component, if it is a polygon.
  final PolygonShape polygonShape;

  @override
  List<Object> get props => [type, polygonShape];
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

/// The user edited the anchor of the selected [AnchoredComponent].
final class ComponentEditorAnchorChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorAnchorChanged] event.
  const new(this.anchor);

  /// The new anchor.
  final ComponentAnchor anchor;

  @override
  List<Object> get props => [anchor];
}

/// The user edited the angle of the selected [RotatedComponent].
final class ComponentEditorAngleChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorAngleChanged] event.
  const new(this.angle);

  /// The new angle.
  final ComponentAngle angle;

  @override
  List<Object> get props => [angle];
}

/// The user edited the radius of the selected [RadiusComponent].
final class ComponentEditorRadiusChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorRadiusChanged] event.
  const new(this.radius);

  /// The new radius.
  final ComponentRadius radius;

  @override
  List<Object> get props => [radius];
}

/// The user edited the vertices of the selected [VerticesComponent].
final class ComponentEditorVerticesChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorVerticesChanged] event.
  const new(this.vertices);

  /// The new vertices.
  final ComponentVertices vertices;

  @override
  List<Object> get props => [vertices];
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

/// The palette of the project changed, e.g. in the palette dialog.
final class ComponentEditorPaletteChanged extends ComponentEditorEvent {
  /// Creates a [ComponentEditorPaletteChanged] event.
  const new(this.palette);

  /// The new palette.
  final Palette palette;

  @override
  List<Object> get props => [palette];
}

/// The user toggled the highlight of the selected node in the preview.
final class ComponentEditorSelectionHighlightToggled
    extends ComponentEditorEvent {
  /// Creates a [ComponentEditorSelectionHighlightToggled] event.
  const new();
}

/// The user zoomed in the preview, to the next of
/// [ZoomLevels].
final class ComponentEditorZoomedIn extends ComponentEditorEvent {
  /// Creates a [ComponentEditorZoomedIn] event.
  const new();
}

/// The user zoomed out the preview, to the previous of
/// [ZoomLevels].
final class ComponentEditorZoomedOut extends ComponentEditorEvent {
  /// Creates a [ComponentEditorZoomedOut] event.
  const new();
}

/// The user reset the zoom of the preview to 100%.
final class ComponentEditorZoomReset extends ComponentEditorEvent {
  /// Creates a [ComponentEditorZoomReset] event.
  const new();
}

/// The user asked to save the component.
final class ComponentEditorSaveRequested extends ComponentEditorEvent {
  /// Creates a [ComponentEditorSaveRequested] event.
  const new();
}
