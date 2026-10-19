import 'package:component_repository/component_repository.dart';

/// A [Component] that has a [ComponentPosition].
///
/// Implemented by every component type backed by a Flame
/// `PositionComponent`. The position is only edited on child components:
/// the root is placed by whoever uses it.
abstract interface class PositionedComponent {
  /// The position of the component, relative to its parent.
  ComponentPosition get position;

  /// Returns a copy of this component with [position] replaced.
  Component copyWithPosition(ComponentPosition position);
}

/// A [Component] that has a [ComponentAnchor].
///
/// Implemented by every component type backed by a Flame
/// `PositionComponent`. Like the position, the anchor is only edited on
/// child components: the root is placed by whoever uses it.
abstract interface class AnchoredComponent {
  /// The point of the component that is placed at its position.
  ComponentAnchor get anchor;

  /// Returns a copy of this component with [anchor] replaced.
  Component copyWithAnchor(ComponentAnchor anchor);
}

/// A [Component] that has a [ComponentSize].
///
/// Implemented by every component type backed by a Flame
/// `PositionComponent`.
abstract interface class SizedComponent {
  /// The size of the component.
  ComponentSize get size;

  /// Returns a copy of this component with [size] replaced.
  Component copyWithSize(ComponentSize size);
}

/// A [Component] that draws with a [ComponentPaint].
abstract interface class PaintedComponent {
  /// The paint of the component.
  ComponentPaint get paint;

  /// Returns a copy of this component with [paint] replaced.
  Component copyWithPaint(ComponentPaint paint);
}

/// A [Component] that has a [ComponentRadius].
///
/// Implemented by round component types, such as circles, whose Flame size
/// is derived from the radius.
abstract interface class RadiusComponent {
  /// The radius of the component.
  ComponentRadius get radius;

  /// Returns a copy of this component with [radius] replaced.
  Component copyWithRadius(ComponentRadius radius);
}
