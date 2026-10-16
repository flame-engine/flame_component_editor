import 'package:component_repository/component_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(RectangleComponent, () {
    const component = RectangleComponent(
      name: 'Player',
      position: ComponentPosition(x: 1, y: 2),
      size: ComponentSize(width: 10, height: 20),
      paint: ComponentPaint(color: 0xFF00FF00, style: PaintStyle.stroke),
      children: [RectangleComponent(name: 'rectangle1')],
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

    test('is a rectangle with a position, a size and a paint', () {
      expect(component.type, equals(ComponentType.rectangle));
      expect(component, isA<PositionedComponent>());
      expect(component, isA<SizedComponent>());
      expect(component, isA<PaintedComponent>());
    });

    test('round-trips through JSON', () {
      expect(Component.fromJson(component.toJson()), equals(component));
    });

    test('toJson includes the type, properties and children', () {
      expect(
        component.toJson(),
        equals({
          'name': 'Player',
          'type': 'rectangle',
          'children': [
            {
              'name': 'rectangle1',
              'type': 'rectangle',
              'children': <Object>[],
              'position': {'x': 0.0, 'y': 0.0},
              'size': {'width': 50.0, 'height': 50.0},
              'paint': {'color': 0xFFFFFFFF, 'style': 'fill'},
            },
          ],
          'position': {'x': 1.0, 'y': 2.0},
          'size': {'width': 10.0, 'height': 20.0},
          'paint': {'color': 0xFF00FF00, 'style': 'stroke'},
        }),
      );
    });

    test('copyWithPosition replaces only the position', () {
      const position = ComponentPosition(x: 5, y: 6);
      final copy = component.copyWithPosition(position);

      expect(copy.position, equals(position));
      expect(
        copy.toJson()..remove('position'),
        equals(component.toJson()..remove('position')),
      );
    });

    test('copyWithSize replaces only the size', () {
      const size = ComponentSize(width: 1, height: 2);
      final copy = component.copyWithSize(size);

      expect(copy.size, equals(size));
      expect(
        copy.toJson()..remove('size'),
        equals(component.toJson()..remove('size')),
      );
    });

    test('copyWithPaint replaces only the paint', () {
      const paint = ComponentPaint(color: 0xFF0000FF);
      final copy = component.copyWithPaint(paint);

      expect(copy.paint, equals(paint));
      expect(
        copy.toJson()..remove('paint'),
        equals(component.toJson()..remove('paint')),
      );
    });

    test('copyWithName replaces only the name', () {
      final copy = component.copyWithName('Enemy');

      expect(copy.name, equals('Enemy'));
      expect(
        copy.toJson()..remove('name'),
        equals(component.toJson()..remove('name')),
      );
    });

    test('copyWithChildren replaces only the children', () {
      final copy = component.copyWithChildren(const []);

      expect(copy.children, isEmpty);
      expect(
        copy.toJson()..remove('children'),
        equals(component.toJson()..remove('children')),
      );
    });
  });
}
