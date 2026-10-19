part of 'component.dart';

/// {@template circle_component}
/// A circle with a position, a radius and a paint.
/// {@endtemplate}
final class CircleComponent extends Component
    implements PositionedComponent, RadiusComponent, PaintedComponent {
  /// {@macro circle_component}
  const new({
    required super.name,
    this.position = const ComponentPosition(),
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
      radius: ComponentRadius.fromJson(json['radius']),
      paint: ComponentPaint.fromJson(json['paint']),
    );
  }

  @override
  ComponentType get type => ComponentType.circle;

  @override
  final ComponentPosition position;

  @override
  final ComponentRadius radius;

  @override
  final ComponentPaint paint;

  @override
  CircleComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
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
    ComponentRadius? radius,
    ComponentPaint? paint,
    List<Component>? children,
  }) {
    return CircleComponent(
      name: name ?? this.name,
      position: position ?? this.position,
      radius: radius ?? this.radius,
      paint: paint ?? this.paint,
      children: children ?? this.children,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'position': position.toJson(),
    'radius': radius.toJson(),
    'paint': paint.toJson(),
  };

  @override
  List<Object> get props => [...super.props, position, radius, paint];
}
