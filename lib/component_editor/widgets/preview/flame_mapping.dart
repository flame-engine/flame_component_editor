import 'package:component_repository/component_repository.dart';
import 'package:flame/components.dart' as flame;
import 'package:flutter/painting.dart';

/// Builds the Flame component that previews the root [component], with its
/// children.
///
/// The root is anchored at its center, at the origin of the world, so it
/// is centered on screen; its stored position is ignored because the root
/// is placed by whoever uses it. Children keep Flame's default top left
/// anchor and are positioned relative to their parent, like in the
/// generated code.
flame.PositionComponent buildFlameComponent(Component component) {
  return _placeRoot(_build(component));
}

flame.PositionComponent _placeRoot(flame.PositionComponent root) {
  root
    ..anchor = flame.Anchor.center
    ..position.setZero();
  return root;
}

flame.PositionComponent _build(Component component) {
  final target = switch (component) {
    RectangleComponent() => flame.RectangleComponent(),
  };
  applyProperties(target, component);
  // Children added before mounting are stored right away, in order.
  component.children.map(_build).forEach(target.add);
  return target;
}

/// Whether [a] and [b] have the same types arranged in the same tree, so
/// that the Flame components built for [a] can be updated to show [b].
bool haveSameShape(Component a, Component b) {
  if (a.type != b.type || a.children.length != b.children.length) {
    return false;
  }
  for (var i = 0; i < a.children.length; i++) {
    if (!haveSameShape(a.children[i], b.children[i])) return false;
  }
  return true;
}

/// Applies the properties of the root [component] and of all of its
/// children to [target] and its children, which must have been built by
/// [buildFlameComponent] for a component of the same shape (see
/// [haveSameShape]).
///
/// Like in [buildFlameComponent], the root stays centered.
void applyTree(flame.PositionComponent target, Component component) {
  _placeRoot(_applyNode(target, component));
}

flame.PositionComponent _applyNode(
  flame.PositionComponent target,
  Component component,
) {
  applyProperties(target, component);
  final children = target.children.whereType<flame.PositionComponent>();
  for (final (index, child) in children.indexed) {
    _applyNode(child, component.children[index]);
  }
  return target;
}

/// The Flame component at [path] in the tree built by
/// [buildFlameComponent] from [root] (see `ComponentTree` for paths).
flame.PositionComponent flameNodeAt(
  flame.PositionComponent root,
  List<int> path,
) {
  var node = root;
  for (final index in path) {
    node = node.children.whereType<flame.PositionComponent>().elementAt(index);
  }
  return node;
}

/// Applies every property [component] has to [target].
///
/// New shared properties should be wired here so that every component type
/// that has them is previewed correctly.
T applyProperties<T extends flame.PositionComponent>(
  T target,
  Component component,
) {
  if (component case final PositionedComponent positioned) {
    applyPosition(target, positioned.position);
  }
  if (component case final SizedComponent sized) {
    applySize(target, sized.size);
  }
  if (component case final PaintedComponent painted
      when target is flame.HasPaint) {
    applyPaint(target as flame.HasPaint, painted.paint);
  }
  return target;
}

/// Applies [position] to [target].
void applyPosition(flame.PositionComponent target, ComponentPosition position) {
  target.position.setValues(position.x, position.y);
}

/// Applies [size] to [target].
void applySize(flame.PositionComponent target, ComponentSize size) {
  target.size.setValues(size.width, size.height);
}

/// Applies [paint] to [target].
void applyPaint(flame.HasPaint target, ComponentPaint paint) {
  target.paint
    ..color = Color(paint.color)
    ..style = switch (paint.style) {
      PaintStyle.fill => PaintingStyle.fill,
      PaintStyle.stroke => PaintingStyle.stroke,
    };
}
