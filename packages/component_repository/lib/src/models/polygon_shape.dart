import 'package:component_repository/component_repository.dart';

/// The shapes a new polygon can start with.
enum PolygonShape {
  /// Three vertices, see [ComponentVertices.triangle].
  triangle(label: 'Triangle', vertices: ComponentVertices.triangle),

  /// Four vertices, see [ComponentVertices.square].
  square(label: 'Square', vertices: ComponentVertices.square);

  new({required this.label, required this.vertices});

  /// Human readable name.
  final String label;

  /// The vertices of the shape.
  final List<ComponentVertex> vertices;
}
