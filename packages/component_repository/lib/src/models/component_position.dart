import 'package:equatable/equatable.dart';

/// {@template component_position}
/// The position property shared by every position based component.
///
/// The position is relative to the parent component.
/// {@endtemplate}
class ComponentPosition extends Equatable {
  /// {@macro component_position}
  const new({this.x = 0, this.y = 0});

  /// Creates a [ComponentPosition] from its JSON representation.
  ///
  /// Missing or invalid values fall back to `0`.
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    return ComponentPosition(
      x: _readCoordinate(map['x']),
      y: _readCoordinate(map['y']),
    );
  }

  /// The horizontal coordinate.
  final double x;

  /// The vertical coordinate.
  final double y;

  /// Returns a copy of this position with the given fields replaced.
  ComponentPosition copyWith({double? x, double? y}) {
    return ComponentPosition(x: x ?? this.x, y: y ?? this.y);
  }

  /// Converts this position to its JSON representation.
  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  static double _readCoordinate(Object? value) {
    return value is num ? value.toDouble() : 0;
  }

  @override
  List<Object> get props => [x, y];
}
