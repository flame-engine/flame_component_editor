import 'dart:math' as math;

import 'package:flame/components.dart' as flame;
import 'package:flutter/painting.dart';

/// {@template preview_position_component}
/// The Flame component that previews a position component.
///
/// A `PositionComponent` draws nothing itself, so the preview outlines it
/// with a faint dashed line, letting users see it while it isn't selected.
/// The outline only exists in the preview: the generated code uses a plain
/// `PositionComponent`.
/// {@endtemplate}
class PreviewPositionComponent extends flame.PositionComponent {
  /// {@macro preview_position_component}
  new();

  /// The color of the outline.
  static const color = Color(0x66FFFFFF);

  /// The length of each dash, and of the gap after it.
  static const dashLength = 4.0;

  static final _paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ];
    for (var i = 0; i < corners.length; i++) {
      _drawDashedLine(canvas, corners[i], corners[(i + 1) % corners.length]);
    }
  }

  static void _drawDashedLine(Canvas canvas, Offset from, Offset to) {
    final length = (to - from).distance;
    if (length == 0) return;
    final direction = (to - from) / length;
    for (var start = 0.0; start < length; start += dashLength * 2) {
      final end = math.min(start + dashLength, length);
      canvas.drawLine(from + direction * start, from + direction * end, _paint);
    }
  }
}
