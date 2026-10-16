import 'package:equatable/equatable.dart';

/// {@template component}
/// A Flame component definition that belongs to a project.
/// {@endtemplate}
class Component extends Equatable {
  /// {@macro component}
  const new({required this.name});

  /// Creates a [Component] from its JSON representation.
  factory fromJson(Map<String, dynamic> json) {
    return Component(name: json['name'] as String);
  }

  /// The component name, which is also used as its class name.
  final String name;

  /// Converts this component to its JSON representation.
  Map<String, dynamic> toJson() => {'name': name};

  @override
  List<Object> get props => [name];
}
