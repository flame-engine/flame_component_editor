import 'package:component_repository/component_repository.dart';
import 'package:equatable/equatable.dart';

/// {@template component_paint}
/// The paint property shared by every component that draws with a paint.
/// {@endtemplate}
class ComponentPaint extends Equatable {
  /// {@macro component_paint}
  const new({this.color = defaultColor, this.style = PaintStyle.fill});

  /// Creates a [ComponentPaint] from its JSON representation.
  ///
  /// Missing or invalid values fall back to their defaults.
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    final color = map['color'];
    return ComponentPaint(
      color: color is int ? color : defaultColor,
      style: PaintStyle.fromName(map['style']) ?? PaintStyle.fill,
    );
  }

  /// The default [color]: opaque white.
  static const defaultColor = 0xFFFFFFFF;

  /// The color as a 32 bit ARGB value.
  final int color;

  /// Whether the shape is filled or stroked.
  final PaintStyle style;

  /// Returns a copy of this paint with the given fields replaced.
  ComponentPaint copyWith({int? color, PaintStyle? style}) {
    return ComponentPaint(
      color: color ?? this.color,
      style: style ?? this.style,
    );
  }

  /// Converts this paint to its JSON representation.
  Map<String, dynamic> toJson() => {'color': color, 'style': style.name};

  @override
  List<Object> get props => [color, style];
}
