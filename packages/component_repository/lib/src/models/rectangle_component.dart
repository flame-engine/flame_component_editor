part of 'component.dart';

/// {@template rectangle_component}
/// A rectangle with a size and a paint.
/// {@endtemplate}
final class RectangleComponent extends Component
    implements SizedComponent, PaintedComponent {
  /// {@macro rectangle_component}
  const new({
    required super.name,
    this.size = const ComponentSize(),
    this.paint = const ComponentPaint(),
  });

  /// Creates a [RectangleComponent] from its JSON representation.
  factory fromJson(Map<String, dynamic> json) {
    return RectangleComponent(
      name: json['name'] as String,
      size: ComponentSize.fromJson(json['size']),
      paint: ComponentPaint.fromJson(json['paint']),
    );
  }

  @override
  ComponentType get type => ComponentType.rectangle;

  @override
  final ComponentSize size;

  @override
  final ComponentPaint paint;

  @override
  RectangleComponent copyWithSize(ComponentSize size) {
    return RectangleComponent(name: name, size: size, paint: paint);
  }

  @override
  RectangleComponent copyWithPaint(ComponentPaint paint) {
    return RectangleComponent(name: name, size: size, paint: paint);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'size': size.toJson(),
    'paint': paint.toJson(),
  };

  @override
  List<Object> get props => [...super.props, size, paint];
}
