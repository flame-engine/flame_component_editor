import 'package:component_repository/component_repository.dart';
import 'package:equatable/equatable.dart';

part 'rectangle_component.dart';

/// {@template component}
/// A Flame component definition that belongs to a project.
///
/// Each subclass is one [ComponentType]. The properties a component has are
/// declared through capability interfaces such as [SizedComponent] and
/// [PaintedComponent], so that editors can be shared between types.
/// {@endtemplate}
sealed class Component extends Equatable {
  /// {@macro component}
  const new({required this.name});

  /// Creates a component of [type] called [name] with default properties.
  factory create(String name, ComponentType type) {
    return switch (type) {
      ComponentType.rectangle => RectangleComponent(name: name),
    };
  }

  /// Creates a [Component] from its JSON representation.
  ///
  /// Components saved without a type are read as rectangles.
  factory fromJson(Map<String, dynamic> json) {
    final type = ComponentType.fromKey(json['type']) ?? ComponentType.rectangle;
    return switch (type) {
      ComponentType.rectangle => RectangleComponent.fromJson(json),
    };
  }

  /// The component name, which is also used as its class name.
  final String name;

  /// The type of this component.
  ComponentType get type;

  /// Converts this component to its JSON representation.
  Map<String, dynamic> toJson() => {'name': name, 'type': type.key};

  @override
  List<Object> get props => [name, type];
}
