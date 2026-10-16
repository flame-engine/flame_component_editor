import 'package:component_repository/component_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComponentTree', () {
    const grandchild = RectangleComponent(name: 'rectangle3');
    const tree = RectangleComponent(
      name: 'Player',
      children: [
        RectangleComponent(name: 'rectangle1', children: [grandchild]),
        RectangleComponent(name: 'rectangle2'),
      ],
    );

    test('nodeAt follows the path from the root', () {
      expect(tree.nodeAt(const []), same(tree));
      expect(tree.nodeAt(const [1]).name, equals('rectangle2'));
      expect(tree.nodeAt(const [0, 0]), equals(grandchild));
      expect(() => tree.nodeAt(const [5]), throwsRangeError);
    });

    test('hasNodeAt tells whether the path exists', () {
      expect(tree.hasNodeAt(const []), isTrue);
      expect(tree.hasNodeAt(const [0, 0]), isTrue);
      expect(tree.hasNodeAt(const [0, 1]), isFalse);
      expect(tree.hasNodeAt(const [-1]), isFalse);
    });

    test('updateNodeAt replaces only the node at the path', () {
      const size = ComponentSize(width: 1);
      final updated = tree.updateNodeAt(const [
        0,
        0,
      ], (node) => (node as SizedComponent).copyWithSize(size));

      expect((updated.nodeAt(const [0, 0]) as SizedComponent).size, size);
      expect(updated.nodeAt(const [1]), equals(tree.nodeAt(const [1])));
      expect(updated.name, equals('Player'));
    });

    test('addChildAt appends a child to the node at the path', () {
      const child = RectangleComponent(name: 'rectangle4');
      final updated = tree.addChildAt(const [1], child);

      expect(updated.nodeAt(const [1]).children, equals([child]));
    });

    test('removeNodeAt removes the node and its children', () {
      final updated = tree.removeNodeAt(const [0]);

      expect(updated.children.map((c) => c.name), equals(['rectangle2']));
      expect(() => tree.removeNodeAt(const []), throwsArgumentError);
    });

    test('nodes lists the tree depth first', () {
      expect(
        tree.nodes.map((node) => node.name),
        equals(['Player', 'rectangle1', 'rectangle3', 'rectangle2']),
      );
    });

    test('uniqueChildName picks the first name that is not taken', () {
      expect(
        tree.uniqueChildName(ComponentType.rectangle),
        equals('rectangle4'),
      );
      expect(
        const RectangleComponent(
          name: 'Player',
          children: [RectangleComponent(name: 'rectangle2')],
        ).uniqueChildName(ComponentType.rectangle),
        equals('rectangle1'),
      );
    });
  });
}
