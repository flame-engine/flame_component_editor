part of 'component.dart';

/// {@template circle_hitbox_component}
/// A round hitbox with a position, an anchor, an angle, a radius and a
/// collision.
/// {@endtemplate}
final class CircleHitboxComponent extends Component
    implements
        PositionedComponent,
        AnchoredComponent,
        RotatedComponent,
        RadiusComponent,
        HitboxComponent {
  /// {@macro circle_hitbox_component}
  const new({
    required super.name,
    this.position = const ComponentPosition(),
    this.anchor = ComponentAnchor.topLeft,
    this.angle = ComponentAngle.zero,
    this.radius = const ComponentRadius(),
    this.collision = const ComponentCollision(),
    super.children,
  });

  /// Reads the properties of a [CircleHitboxComponent] from its JSON
  /// representation. Use [Component.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return CircleHitboxComponent(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      anchor: ComponentAnchor.fromJson(json['anchor']),
      angle: ComponentAngle.fromJson(json['angle']),
      radius: ComponentRadius.fromJson(json['radius']),
      collision: ComponentCollision.fromJson(json['collision']),
    );
  }

  @override
  ComponentType get type => ComponentType.circleHitbox;

  @override
  final ComponentPosition position;

  @override
  final ComponentAnchor anchor;

  @override
  final ComponentAngle angle;

  @override
  final ComponentRadius radius;

  @override
  final ComponentCollision collision;

  @override
  CircleHitboxComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  CircleHitboxComponent copyWithAnchor(ComponentAnchor anchor) {
    return _copyWith(anchor: anchor);
  }

  @override
  CircleHitboxComponent copyWithAngle(ComponentAngle angle) {
    return _copyWith(angle: angle);
  }

  @override
  CircleHitboxComponent copyWithRadius(ComponentRadius radius) {
    return _copyWith(radius: radius);
  }

  @override
  CircleHitboxComponent copyWithCollision(ComponentCollision collision) {
    return _copyWith(collision: collision);
  }

  @override
  CircleHitboxComponent copyWithName(String name) => _copyWith(name: name);

  @override
  CircleHitboxComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  CircleHitboxComponent _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentAnchor? anchor,
    ComponentAngle? angle,
    ComponentRadius? radius,
    ComponentCollision? collision,
    List<Component>? children,
  }) {
    return CircleHitboxComponent(
      name: name ?? this.name,
      position: position ?? this.position,
      anchor: anchor ?? this.anchor,
      angle: angle ?? this.angle,
      radius: radius ?? this.radius,
      collision: collision ?? this.collision,
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
    'collision': collision.toJson(),
  };

  @override
  List<Object> get props => [
    ...super.props,
    position,
    anchor,
    angle,
    radius,
    collision,
  ];
}
