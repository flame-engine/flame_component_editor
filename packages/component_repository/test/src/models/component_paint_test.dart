import 'package:component_repository/component_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentPaint, () {
    test('defaults to a white fill', () {
      const paint = ComponentPaint();

      expect(paint.color, equals(0xFFFFFFFF));
      expect(paint.style, equals(PaintStyle.fill));
    });

    test('round-trips through JSON', () {
      const paint = ComponentPaint(color: 0x80FF0000, style: PaintStyle.stroke);

      expect(ComponentPaint.fromJson(paint.toJson()), equals(paint));
    });

    test('falls back to defaults for missing or invalid values', () {
      expect(ComponentPaint.fromJson(null), equals(const ComponentPaint()));
      expect(
        ComponentPaint.fromJson(const {'color': 'red', 'style': 'dotted'}),
        equals(const ComponentPaint()),
      );
    });

    test('copyWith replaces the given fields', () {
      expect(
        const ComponentPaint().copyWith(color: 0xFF000000),
        equals(const ComponentPaint(color: 0xFF000000)),
      );
      expect(
        const ComponentPaint().copyWith(style: PaintStyle.stroke),
        equals(const ComponentPaint(style: PaintStyle.stroke)),
      );
    });
  });
}
