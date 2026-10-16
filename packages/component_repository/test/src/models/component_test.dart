import 'package:component_repository/component_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(Component, () {
    test('supports value equality', () {
      expect(
        const Component(name: 'Player'),
        equals(const Component(name: 'Player')),
      );
    });

    test('round-trips through JSON', () {
      const component = Component(name: 'Player');

      expect(Component.fromJson(component.toJson()), equals(component));
    });
  });
}
