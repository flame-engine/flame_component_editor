import 'package:component_repository/component_repository.dart';
import 'package:equatable/equatable.dart';

part 'rectangle_component.dart';

/// {@template component}
/// A Flame component definition that belongs to a project.
///
/// Each subclass is one [ComponentType]. The properties a component has are
/// declared through capability interfaces such as [SizedComponent] and
/// [PaintedComponent], so that editors can be shared between types.
///
/// Like in Flame, a component can have [children]; see [ComponentTree] to
/// navigate and edit them.
/// {@endtemplate}
sealed class Component extends Equatable {
  /// {@macro component}
  const new({required this.name, this.children = const []});

  /// Creates a component of [type] called [name] with default properties.
  factory create(String name, ComponentType type) {
    return switch (type) {
      ComponentType.rectangle => RectangleComponent(name: name),
    };
  }

  /// Creates a [Component] from its JSON representation.
  ///
  /// Components saved without a type are read as rectangles. The children
  /// are read here, for every type, so subtypes only read their own
  /// properties.
  factory fromJson(Map<String, dynamic> json) {
    final type = ComponentType.fromKey(json['type']) ?? ComponentType.rectangle;
    final component = switch (type) {
      ComponentType.rectangle => RectangleComponent._fromJson(json),
    };
    return component.copyWithChildren(_childrenFromJson(json['children']));
  }

  static List<Component> _childrenFromJson(Object? json) {
    return [
      if (json is List)
        for (final child in json)
          if (child is Map<String, dynamic>) Component.fromJson(child),
    ];
  }

  /// The component name.
  ///
  /// The root component name is used as its class name.
  final String name;

  /// The components added to this one.
  final List<Component> children;

  /// The type of this component.
  ComponentType get type;

  /// Returns a copy of this component called [name].
  Component copyWithName(String name);

  /// Returns a copy of this component with [children] replaced.
  Component copyWithChildren(List<Component> children);

  /// Converts this component to its JSON representation.
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.key,
    'children': [for (final child in children) child.toJson()],
  };

  @override
  List<Object> get props => [name, type, children];
}
