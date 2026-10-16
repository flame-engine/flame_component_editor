import 'package:component_repository/component_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentType, () {
    test('fromKey returns the matching type', () {
      expect(
        ComponentType.fromKey('rectangle'),
        equals(ComponentType.rectangle),
      );
    });

    test('fromKey returns null for unknown keys', () {
      expect(ComponentType.fromKey('circle'), isNull);
      expect(ComponentType.fromKey(null), isNull);
    });
  });

  group(PaintStyle, () {
    test('fromName returns the matching style', () {
      expect(PaintStyle.fromName('stroke'), equals(PaintStyle.stroke));
    });

    test('fromName returns null for unknown names', () {
      expect(PaintStyle.fromName('dotted'), isNull);
    });
  });
}
