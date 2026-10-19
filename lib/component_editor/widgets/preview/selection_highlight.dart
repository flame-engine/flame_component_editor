import 'package:flame/components.dart' as flame;
import 'package:flutter/painting.dart';

/// {@template selection_highlight}
/// Draws a thick magenta border around [target], the Flame component of
/// the node selected in the editor.
///
/// It is added to the world, above everything else, instead of to
/// [target]: that keeps it on top of overlapping siblings, and the
/// children of the previewed components match the component tree.
/// {@endtemplate}
class SelectionHighlight extends flame.Component {
  /// {@macro selection_highlight}
  new() : super(priority: 1 << 30);

  /// The color of the border.
  static const color = Color(0xFFFF00FF);

  /// The width of the border.
  static const strokeWidth = 4.0;

  static final _paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;

  /// The component to highlight, if any.
  flame.PositionComponent? target;

  @override
  void render(Canvas canvas) {
    final target = this.target;
    if (target == null || !target.isMounted) return;
    // Drawn outside of the component, so it doesn't hide its own edges.
    canvas.drawRect(target.toAbsoluteRect().inflate(strokeWidth / 2), _paint);
  }
}
