import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/vertices_editor/widgets/vertices_view_transform.dart';
import 'package:flutter/material.dart';

/// {@template vertices_painter}
/// Draws the polygon edited in the vertices editor with its own paint, its
/// bounding box, the origin of its local coordinates, and the handles that
/// move its vertices and add new ones.
/// {@endtemplate}
class VerticesPainter extends CustomPainter {
  /// {@macro vertices_painter}
  const new({
    required this.vertices,
    required this.transform,
    required this.polygonPaint,
    this.selectedIndex,
    this.hoveredEdge,
  });

  /// The color of the handles, the guides and the selection.
  static const accentColor = Color(0xFFFF00FF);

  /// The color of the guides.
  static const guideColor = Color(0x66FFFFFF);

  /// The radius of the vertex handles.
  static const handleRadius = 6.0;

  /// The vertices of the polygon.
  final List<ComponentVertex> vertices;

  /// Where the vertices are drawn.
  final VerticesViewTransform transform;

  /// The paint of the polygon.
  final ComponentPaint polygonPaint;

  /// The index of the selected vertex, if any.
  final int? selectedIndex;

  /// The index of the edge (by its first vertex) under the pointer, whose
  /// midpoint handle adds a vertex.
  final int? hoveredEdge;

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = guideColor
      ..style = PaintingStyle.stroke;

    // The origin of the local coordinates.
    final origin = transform.toCanvas(const ComponentVertex(0, 0));
    canvas
      ..drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), guide)
      ..drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), guide);

    // The bounding box, which is the size of the component.
    final bounds = VerticesViewTransform.boundsOf(vertices);
    canvas.drawRect(
      Rect.fromPoints(
        transform.toCanvas(ComponentVertex(bounds.left, bounds.top)),
        transform.toCanvas(ComponentVertex(bounds.right, bounds.bottom)),
      ),
      guide,
    );

    final path = Path()
      ..addPolygon(vertices.map(transform.toCanvas).toList(), true);
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = Color(polygonPaint.color)
          ..style = switch (polygonPaint.style) {
            PaintStyle.fill => PaintingStyle.fill,
            PaintStyle.stroke => PaintingStyle.stroke,
          },
      )
      // The edges, which stay visible whatever the paint is.
      ..drawPath(
        path,
        Paint()
          ..color = accentColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke,
      );

    if (hoveredEdge case final edge? when edge < vertices.length) {
      _paintAddHandle(canvas, transform.midpointOf(vertices, edge));
    }

    for (final (index, vertex) in vertices.indexed) {
      final center = transform.toCanvas(vertex);
      canvas
        ..drawCircle(
          center,
          handleRadius,
          Paint()..color = index == selectedIndex ? accentColor : Colors.white,
        )
        ..drawCircle(
          center,
          handleRadius,
          Paint()
            ..color = accentColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
  }

  void _paintAddHandle(Canvas canvas, Offset center) {
    const arm = handleRadius - 2;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas
      ..drawCircle(center, handleRadius, Paint()..color = accentColor)
      ..drawLine(
        center - const Offset(arm, 0),
        center + const Offset(arm, 0),
        stroke,
      )
      ..drawLine(
        center - const Offset(0, arm),
        center + const Offset(0, arm),
        stroke,
      );
  }

  @override
  bool shouldRepaint(VerticesPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.transform != transform ||
        oldDelegate.polygonPaint != polygonPaint ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.hoveredEdge != hoveredEdge;
  }
}
