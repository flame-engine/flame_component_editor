import 'package:component_repository/component_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(Component, () {
    group('create', () {
      test('creates a rectangle with default properties', () {
        expect(
          Component.create('Player', ComponentType.rectangle),
          equals(const RectangleComponent(name: 'Player')),
        );
      });
    });

    group('fromJson', () {
      test('reads a rectangle', () {
        expect(
          Component.fromJson(const {'name': 'Player', 'type': 'rectangle'}),
          isA<RectangleComponent>(),
        );
      });

      test('reads the children and skips invalid ones', () {
        expect(
          Component.fromJson(const {
            'name': 'Player',
            'children': [
              {'name': 'rectangle1', 'type': 'rectangle'},
              'invalid',
            ],
          }),
          equals(
            const RectangleComponent(
              name: 'Player',
              children: [RectangleComponent(name: 'rectangle1')],
            ),
          ),
        );
      });

      test('reads components without a type as rectangles', () {
        expect(
          Component.fromJson(const {'name': 'Player'}),
          equals(const RectangleComponent(name: 'Player')),
        );
      });
    });
  });
}
