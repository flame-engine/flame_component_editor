import 'package:component_repository/component_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(RectangleComponent, () {
    const component = RectangleComponent(
      name: 'Player',
      size: ComponentSize(width: 10, height: 20),
      paint: ComponentPaint(color: 0xFF00FF00, style: PaintStyle.stroke),
    );

    test('supports value equality', () {
      expect(
        const RectangleComponent(name: 'Player'),
        equals(const RectangleComponent(name: 'Player')),
      );
      expect(
        component,
        isNot(equals(const RectangleComponent(name: 'Player'))),
      );
    });

    test('is a rectangle with a size and a paint', () {
      expect(component.type, equals(ComponentType.rectangle));
      expect(component, isA<SizedComponent>());
      expect(component, isA<PaintedComponent>());
    });

    test('round-trips through JSON', () {
      expect(Component.fromJson(component.toJson()), equals(component));
    });

    test('toJson includes the type, size and paint', () {
      expect(
        component.toJson(),
        equals({
          'name': 'Player',
          'type': 'rectangle',
          'size': {'width': 10.0, 'height': 20.0},
          'paint': {'color': 0xFF00FF00, 'style': 'stroke'},
        }),
      );
    });

    test('copyWithSize replaces only the size', () {
      const size = ComponentSize(width: 1, height: 2);

      expect(
        component.copyWithSize(size),
        equals(
          RectangleComponent(
            name: 'Player',
            size: size,
            paint: component.paint,
          ),
        ),
      );
    });

    test('copyWithPaint replaces only the paint', () {
      const paint = ComponentPaint(color: 0xFF0000FF);

      expect(
        component.copyWithPaint(paint),
        equals(
          RectangleComponent(
            name: 'Player',
            size: component.size,
            paint: paint,
          ),
        ),
      );
    });
  });
}
