part of 'component.dart';

/// {@template circle_component}
/// A circle with a position, an anchor, an angle, a radius and a paint.
/// {@endtemplate}
final class CircleComponent extends Component
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        RadiusComponent,
        PaintedComponent {
  /// {@macro circle_component}
  const new({
    required super.name,
    this.position = const ComponentPosition(),
    this.anchor = ComponentAnchor.topLeft,
    this.angle = ComponentAngle.zero,
    this.radius = const ComponentRadius(),
    this.paint = const ComponentPaint(),
    super.children,
  });

  /// Reads the properties of a [CircleComponent] from its JSON
  /// representation. Use [Component.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return CircleComponent(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      radius: ComponentRadius.fromJson(json['radius']),
      paint: ComponentPaint.fromJson(json['paint']),
    );
  }

  @override
  ComponentType get type => ComponentType.circle;

  @override
  final ComponentPosition position;

  @override
  final ComponentAnchor anchor;

  @override
  final ComponentAngle angle;

  @override
  final ComponentRadius radius;

  @override
  final ComponentPaint paint;

  @override
  CircleComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  CircleComponent copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  CircleComponent copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  CircleComponent copyWithRadius(ComponentRadius radius) {
    return _copyWith(radius: radius);
  }

  @override
  CircleComponent copyWithPaint(ComponentPaint paint) {
    return _copyWith(paint: paint);
  }

  @override
  CircleComponent copyWithName(String name) => _copyWith(name: name);

  @override
  CircleComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  CircleComponent _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentRadius? radius,
    ComponentPaint? paint,
    List<Component>? children,
  }) {
    return CircleComponent(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      radius: radius ?? this.radius,
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
    'radius': radius.toJson(),
    'paint': paint.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    radius,
    paint,
  ];
}
