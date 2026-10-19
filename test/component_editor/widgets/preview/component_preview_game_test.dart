import 'package:component_repository/component_repository.dart';
import 'package:flame/components.dart' as flame;
import 'package:flame_component_editor/component_editor/widgets/widgets.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCanvas extends Mock implements Canvas;

void main() {
  setUpAll(() {
    registerFallbackValue(Offset.zero);
    registerFallbackValue(Paint());
  });

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

        game.show(
          component.copyWithSize(const ComponentSize(width: 30, height: 40)),
        );

        expect(game.preview, same(preview));
        expect(preview.size, equals(flame.Vector2(30, 40)));
      },
    );

    testWithGame(
      'renders position components with a preview-only outline',
      () => ComponentPreviewGame(
        component: const PositionComponent(
          name: 'Player',
          size: ComponentSize(width: 10, height: 20),
          children: [
            PositionComponent(
              name: 'position1',
              position: ComponentPosition(x: 5, y: 6),
              size: ComponentSize(width: 1, height: 2),
            ),
          ],
        ),
      ),
      (game) async {
        await game.ready();

        final preview = game.preview;
        expect(preview, isA<PreviewPositionComponent>());
        expect(preview.size, equals(flame.Vector2(10, 20)));
        final child = preview.children.single as flame.PositionComponent;
        expect(child, isA<PreviewPositionComponent>());
        expect(child.position, equals(flame.Vector2(5, 6)));
        expect(child.size, equals(flame.Vector2(1, 2)));
      },
    );

    testWithGame(
      'renders circles with their radius and paint',
      () => ComponentPreviewGame(
        component: const CircleComponent(
          name: 'Player',
          radius: ComponentRadius(radius: 10),
          paint: ComponentPaint(color: 0xFF00FF00),
          children: [
            CircleComponent(
              name: 'circle1',
              position: ComponentPosition(x: 5, y: 6),
              radius: ComponentRadius(radius: 2),
            ),
          ],
        ),
      ),
      (game) async {
        await game.ready();

        final preview = game.preview as flame.CircleComponent;
        expect(preview.radius, equals(10));
        expect(preview.size, equals(flame.Vector2(20, 20)));
        expect(preview.paint.color, equals(const Color(0xFF00FF00)));
        final child = preview.children.single as flame.CircleComponent;
        expect(child.position, equals(flame.Vector2(5, 6)));
        expect(child.radius, equals(2));

        game.show(
          const CircleComponent(
            name: 'Player',
            radius: ComponentRadius(radius: 15),
            children: [CircleComponent(name: 'circle1')],
          ),
          highlightedPath: [0],
        );

        expect(game.preview, same(preview));
        expect(preview.radius, equals(15));
        expect(game.highlight.target, same(child));
      },
    );

    group('with children', () {
      const child = RectangleComponent(
        name: 'rectangle1',
        position: ComponentPosition(x: 5, y: 6),
        size: ComponentSize(width: 1, height: 2),
      );
      final tree = component.copyWithChildren(const [child]);

      testWithGame(
        'renders the children relative to their parent',
        () => ComponentPreviewGame(component: tree),
        (game) async {
          await game.ready();

          final children = game.preview.children
              .whereType<flame.RectangleComponent>()
              .toList();
          expect(children, hasLength(1));
          expect(children.single.anchor, equals(flame.Anchor.topLeft));
          expect(children.single.position, equals(flame.Vector2(5, 6)));
          expect(children.single.size, equals(flame.Vector2(1, 2)));
        },
      );

      testWithGame(
        'anchors the children with their anchor',
        () => ComponentPreviewGame(
          component: component.copyWithChildren([
            child.copyWithAnchor(const ComponentAnchor(x: 0.25, y: 1)),
          ]),
        ),
        (game) async {
          await game.ready();

          final rendered = game.preview.children
              .whereType<flame.PositionComponent>()
              .single;
          expect(rendered.anchor, equals(const flame.Anchor(0.25, 1)));
        },
      );

      testWithGame(
        'rotates the children with their angle',
        () => ComponentPreviewGame(
          component: component.copyWithChildren([
            child.copyWithAngle(const ComponentAngle(radians: 1)),
          ]),
        ),
        (game) async {
          await game.ready();

          final rendered = game.preview.children
              .whereType<flame.PositionComponent>()
              .single;
          expect(rendered.angle, equals(1));
        },
      );

      testWithGame(
        'show updates the children in place',
        () => ComponentPreviewGame(component: tree),
        (game) async {
          await game.ready();
          final preview = game.preview;

          game.show(
            component.copyWithChildren([
              child.copyWithPosition(const ComponentPosition(x: -3)),
            ]),
          );

          expect(game.preview, same(preview));
          final rendered = preview.children
              .whereType<flame.PositionComponent>()
              .single;
          expect(rendered.position, equals(flame.Vector2(-3, 0)));
        },
      );

      testWithGame(
        'show rebuilds when children are added',
        () => ComponentPreviewGame(component: component),
        (game) async {
          await game.ready();
          final preview = game.preview;

          game.show(tree);
          await game.ready();

          expect(game.preview, isNot(same(preview)));
          expect(game.world.children, isNot(contains(preview)));
          expect(game.preview.children, hasLength(1));
        },
      );
    });

    testWithGame(
      'renders polygons with their vertices',
      () => ComponentPreviewGame(
        component: const PolygonComponent(
          name: 'Player',
          children: [
            PolygonComponent(
              name: 'polygon1',
              vertices: ComponentVertices(ComponentVertices.square),
            ),
          ],
        ),
        highlightedPath: [0],
      ),
      (game) async {
        await game.ready();

        final preview = game.preview as flame.PolygonComponent;
        expect(preview.vertices, hasLength(3));
        expect(preview.size, equals(flame.Vector2(50, 50)));
        final child = flameNodeAt(preview, [0]) as flame.PolygonComponent;
        expect(child.vertices, hasLength(4));
        expect(game.highlight.target, same(child));
      },
    );

    testWithGame(
      'rebuilds polygons whose vertices changed',
      () => ComponentPreviewGame(
        component: const PolygonComponent(name: 'Player'),
      ),
      (game) async {
        await game.ready();
        final preview = game.preview;

        game.show(
          const PolygonComponent(
            name: 'Player',
            vertices: ComponentVertices(ComponentVertices.square),
          ),
        );
        await game.ready();

        expect(game.preview, isNot(same(preview)));
        expect((game.preview as flame.PolygonComponent).vertices, hasLength(4));
      },
    );

    group('highlight', () {
      const child = RectangleComponent(name: 'rectangle1');
      final tree = component.copyWithChildren(const [child]);

      testWithGame(
        'targets the root',
        () => ComponentPreviewGame(component: component, highlightedPath: []),
        (game) async {
          await game.ready();

          expect(game.world.children, contains(game.highlight));
          expect(game.highlight.target, same(game.preview));
        },
      );

      testWithGame(
        'targets nothing without a path',
        () => ComponentPreviewGame(component: component),
        (game) async {
          await game.ready();

          expect(game.highlight.target, isNull);
        },
      );

      testWithGame(
        'follows the highlighted path',
        () => ComponentPreviewGame(component: tree, highlightedPath: []),
        (game) async {
          await game.ready();

          game.show(tree, highlightedPath: [0]);
          expect(game.highlight.target, same(flameNodeAt(game.preview, [0])));

          game.show(tree);
          expect(game.highlight.target, isNull);
        },
      );

      testWithGame(
        'targets the rebuilt component',
        () => ComponentPreviewGame(component: component, highlightedPath: []),
        (game) async {
          await game.ready();

          game.show(tree, highlightedPath: [0]);
          await game.ready();

          final rendered = game.preview.children
              .whereType<flame.PositionComponent>()
              .single;
          expect(game.highlight.target, same(rendered));
        },
      );

      testWithGame(
        'ignores paths outside of the tree',
        () => ComponentPreviewGame(component: component, highlightedPath: [3]),
        (game) async {
          await game.ready();

          expect(game.highlight.target, isNull);
        },
      );
    });

    test('haveSameShape compares the types and the tree', () {
      const child = RectangleComponent(name: 'rectangle1');

      expect(
        haveSameShape(
          component,
          component.copyWithSize(const ComponentSize(width: 1)),
        ),
        isTrue,
      );
      expect(
        haveSameShape(component, component.copyWithChildren(const [child])),
        isFalse,
      );
      const polygon = PolygonComponent(name: 'Player');
      expect(
        haveSameShape(
          polygon,
          polygon.copyWithPaint(const ComponentPaint(color: 0xFF000000)),
        ),
        isTrue,
      );
      expect(
        haveSameShape(
          polygon,
          polygon.copyWithVertices(
            const ComponentVertices(ComponentVertices.square),
          ),
        ),
        isFalse,
      );
    });

    testWithGame(
      'keeps the root centered and not rotated whatever its stored '
      'position, anchor and angle',
      () => ComponentPreviewGame(
        component: component
            .copyWithPosition(const ComponentPosition(x: 100, y: 100))
            .copyWithAnchor(ComponentAnchor.bottomRight)
            .copyWithAngle(const ComponentAngle(radians: 1)),
      ),
      (game) async {
        await game.ready();
        expect(game.preview.position, equals(flame.Vector2.zero()));
        expect(game.preview.anchor, equals(flame.Anchor.center));
        expect(game.preview.angle, equals(0));

        game.show(
          component.copyWithPosition(const ComponentPosition(x: 7, y: 8)),
        );
        expect(game.preview.position, equals(flame.Vector2.zero()));
      },
    );

    test('show before loading keeps the component for later', () {
      final game = ComponentPreviewGame(component: component)
        ..show(component.copyWithSize(const ComponentSize(width: 1)));

      expect(game.isLoaded, isFalse);
    });
  });

  group(PreviewPositionComponent, () {
    test('draws a dashed outline around its size', () {
      final canvas = _MockCanvas();
      // Edges of 16 and 8 hold two and one 4px dashes respectively.
      PreviewPositionComponent()
        ..size.setValues(16, 8)
        ..render(canvas);

      final starts = verify(() => canvas.drawLine(captureAny(), any(), any()))
          .captured;
      expect(starts, hasLength(6));
      expect(starts.first, equals(Offset.zero));
    });

    test('draws nothing without a size', () {
      final canvas = _MockCanvas();
      PreviewPositionComponent().render(canvas);

      verifyNever(() => canvas.drawLine(any(), any(), any()));
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
