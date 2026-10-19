/// The kinds of components the editor can create.
///
/// Each value maps to a Flame component class.
enum ComponentType {
  /// A rectangle, backed by Flame's `RectangleComponent`.
  rectangle(key: 'rectangle', label: 'Rectangle'),

  /// A plain component that draws nothing itself, backed by Flame's
  /// `PositionComponent`.
  position(key: 'position', label: 'Position');

  new({required this.key, required this.label});

  /// Returns the type stored under [key], or `null` if there is none.
  static ComponentType? fromKey(Object? key) {
    for (final type in values) {
      if (type.key == key) return type;
    }
    return null;
  }

  /// The value stored in the component JSON.
  final String key;

  /// Human readable name.
  final String label;
}
