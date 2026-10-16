part of 'component.dart';

/// {@template rectangle_component}
/// A rectangle with a position, a size and a paint.
/// {@endtemplate}
final class RectangleComponent extends Component
    implements PositionedComponent, SizedComponent, PaintedComponent {
  /// {@macro rectangle_component}
  const new({
    required super.name,
    this.position = const ComponentPosition(),
    this.size = const ComponentSize(),
    this.paint = const ComponentPaint(),
    super.children,
  });

  /// Creates a [RectangleComponent] from its JSON representation.
  factory fromJson(Map<String, dynamic> json) {
    return RectangleComponent(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      size: ComponentSize.fromJson(json['size']),
      paint: ComponentPaint.fromJson(json['paint']),
      children: Component._childrenFromJson(json['children']),
    );
  }

  @override
  ComponentType get type => ComponentType.rectangle;

  @override
  final ComponentPosition position;

  @override
  final ComponentSize size;

  @override
  final ComponentPaint paint;

  @override
  RectangleComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  RectangleComponent copyWithSize(ComponentSize size) {
    return _copyWith(size: size);
  }

  @override
  RectangleComponent copyWithPaint(ComponentPaint paint) {
    return _copyWith(paint: paint);
  }

  @override
  RectangleComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  RectangleComponent _copyWith({
    ComponentPosition? position,
    ComponentSize? size,
    ComponentPaint? paint,
    List<Component>? children,
  }) {
    return RectangleComponent(
      name: name,
      position: position ?? this.position,
      size: size ?? this.size,
      paint: paint ?? this.paint,
      children: children ?? this.children,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'position': position.toJson(),
    'size': size.toJson(),
    'paint': paint.toJson(),
  };

  @override
  List<Object> get props => [...super.props, position, size, paint];
}
