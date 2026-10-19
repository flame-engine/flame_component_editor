part of 'component.dart';

/// {@template position_component}
/// A plain component with a position and a size, that draws nothing itself:
/// a container for its children.
/// {@endtemplate}
final class PositionComponent extends Component
    implements PositionedComponent, SizedComponent {
  /// {@macro position_component}
  const new({
    required super.name,
    this.position = const ComponentPosition(),
    this.size = const ComponentSize(),
    super.children,
  });

  /// Reads the properties of a [PositionComponent] from its JSON
  /// representation. Use [Component.fromJson], which also reads the
  /// children.
  factory _fromJson(Map<String, dynamic> json) {
    return PositionComponent(
      name: json['name'] as String,
      position: ComponentPosition.fromJson(json['position']),
      size: ComponentSize.fromJson(json['size']),
    );
  }

  @override
  ComponentType get type => ComponentType.position;

  @override
  final ComponentPosition position;

  @override
  final ComponentSize size;

  @override
  PositionComponent copyWithPosition(ComponentPosition position) {
    return _copyWith(position: position);
  }

  @override
  PositionComponent copyWithSize(ComponentSize size) {
    return _copyWith(size: size);
  }

  @override
  PositionComponent copyWithName(String name) => _copyWith(name: name);

  @override
  PositionComponent copyWithChildren(List<Component> children) {
    return _copyWith(children: children);
  }

  PositionComponent _copyWith({
    String? name,
    ComponentPosition? position,
    ComponentSize? size,
    List<Component>? children,
  }) {
    return PositionComponent(
      name: name ?? this.name,
      position: position ?? this.position,
      size: size ?? this.size,
      children: children ?? this.children,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'position': position.toJson(),
    'size': size.toJson(),
  };

  @override
  List<Object> get props => [...super.props, position, size];
}
