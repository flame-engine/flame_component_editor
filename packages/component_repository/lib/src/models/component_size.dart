import 'package:equatable/equatable.dart';

/// {@template component_size}
/// The size property shared by every position based component.
/// {@endtemplate}
class ComponentSize extends Equatable {
  /// {@macro component_size}
  const new({this.width = defaultValue, this.height = defaultValue});

  /// Creates a [ComponentSize] from its JSON representation.
  ///
  /// Missing or invalid values fall back to [defaultValue].
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    return ComponentSize(
      width: _readDimension(map['width']),
      height: _readDimension(map['height']),
    );
  }

  /// The default [width] and [height].
  static const defaultValue = 50.0;

  /// The width.
  final double width;

  /// The height.
  final double height;

  /// Returns a copy of this size with the given fields replaced.
  ComponentSize copyWith({double? width, double? height}) {
    return ComponentSize(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  /// Converts this size to its JSON representation.
  Map<String, dynamic> toJson() => {'width': width, 'height': height};

  static double _readDimension(Object? value) {
    return value is num && value >= 0 ? value.toDouble() : defaultValue;
  }

  @override
  List<Object> get props => [width, height];
}
