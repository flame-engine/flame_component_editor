import 'package:component_repository/component_repository.dart';

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
