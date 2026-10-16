import 'package:component_repository/component_repository.dart';
import 'package:flame/components.dart' as flame;
import 'package:flutter/painting.dart';

/// Builds the Flame component that previews [component].
///
/// The component is anchored at its center and has every property of
/// [component] applied with [applyProperties].
flame.PositionComponent buildFlameComponent(Component component) {
  final preview = switch (component) {
    RectangleComponent() => flame.RectangleComponent(),
  };
  return applyProperties(preview..anchor = flame.Anchor.center, component);
}

/// Applies every property [component] has to [target].
///
/// New shared properties should be wired here so that every component type
/// that has them is previewed correctly.
T applyProperties<T extends flame.PositionComponent>(
  T target,
  Component component,
) {
  if (component case final SizedComponent sized) {
    applySize(target, sized.size);
  }
  if (component case final PaintedComponent painted
      when target is flame.HasPaint) {
    applyPaint(target as flame.HasPaint, painted.paint);
  }
  return target;
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
