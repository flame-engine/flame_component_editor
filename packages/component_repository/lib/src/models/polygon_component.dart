part of 'component.dart';

/// {@template polygon_component}
/// A polygon with a position, an anchor, an angle, vertices and a paint.
///
/// Its size is the bounding box of its vertices.
/// {@endtemplate}
final class PolygonComponent extends Component
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        VerticesComponent,
        PaintedComponent {
  /// {@macro polygon_component}
  const new({
    required super.name,
    this.position = const ComponentPosition(),
    this.anchor = ComponentAnchor.topLeft,
    this.angle = ComponentAngle.zero,
    this.vertices = const ComponentVertices(),
    this.paint = const ComponentPaint(),
    super.children,
  });

  /// Reads the properties of a [PolygonComponent] from its JSON
  /// representation. Use [Component.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return PolygonComponent(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      vertices: ComponentVertices.fromJson(json['vertices']),
      paint: ComponentPaint.fromJson(json['paint']),
    );
  }

  @override
  ComponentType get type => ComponentType.polygon;

  @override
  final ComponentPosition position;

  @override
  final ComponentAnchor anchor;

  @override
  final ComponentAngle angle;

  @override
  final ComponentVertices vertices;

  @override
  final ComponentPaint paint;

  @override
  PolygonComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  PolygonComponent copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  PolygonComponent copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  PolygonComponent copyWithVertices(ComponentVertices vertices) {
    return _copyWith(vertices: vertices);
  }

  @override
  PolygonComponent copyWithPaint(ComponentPaint paint) {
    return _copyWith(paint: paint);
  }

  @override
  PolygonComponent copyWithName(String name) => _copyWith(name: name);

  @override
  PolygonComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  PolygonComponent _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentVertices? vertices,
    ComponentPaint? paint,
    List<Component>? children,
  }) {
    return PolygonComponent(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      vertices: vertices ?? this.vertices,
      paint: paint ?? this.paint,
      children: children ?? this.children,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'position': position.toJson(),
    'anchor': anchor.toJson(),
    'angle': angle.toJson(),
    'vertices': vertices.toJson(),
    'paint': paint.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    vertices,
    paint,
  ];
}
