import 'package:component_repository/component_repository.dart';
import 'package:flame/components.dart' as flame;
import 'package:flame_component_editor/component_editor/widgets/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const component = RectangleComponent(
    name: 'Player',
    size: ComponentSize(width: 10, height: 20),
    paint: ComponentPaint(color: 0xFFFF0000, style: PaintStyle.stroke),
  );

  group(ComponentPreviewGame, () {
    testWithGame(
      'renders the component at the center of the world',
      () => ComponentPreviewGame(component: component),
      (game) async {
        await game.ready();

        final preview = game.preview as flame.RectangleComponent;
        expect(game.world.children, contains(preview));
        expect(preview.anchor, equals(flame.Anchor.center));
        expect(preview.size, equals(flame.Vector2(10, 20)));
        expect(preview.paint.color, equals(const Color(0xFFFF0000)));
        expect(preview.paint.style, equals(PaintingStyle.stroke));
      },
    );

    testWithGame(
      'show updates the component in place',
      () => ComponentPreviewGame(component: component),
      (game) async {
        await game.ready();
        final preview = game.preview;

        await game.show(
          component.copyWithSize(const ComponentSize(width: 30, height: 40)),
        );

        expect(game.preview, same(preview));
        expect(preview.size, equals(flame.Vector2(30, 40)));
      },
    );

    test('show before loading keeps the component for later', () async {
      final game = ComponentPreviewGame(component: component);

      await game.show(component.copyWithSize(const ComponentSize(width: 1)));

      expect(game.isLoaded, isFalse);
    });
  });

  group('applyPaint', () {
    test('maps the fill style', () {
      final target = flame.RectangleComponent();

      applyPaint(target, const ComponentPaint(color: 0xFF00FF00));

      expect(target.paint.color, equals(const Color(0xFF00FF00)));
      expect(target.paint.style, equals(PaintingStyle.fill));
    });
  });
}
