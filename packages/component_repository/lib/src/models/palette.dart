import 'package:component_repository/src/code_generation/dart_names.dart';
import 'package:equatable/equatable.dart';

/// Why a name can't be used for a [PaletteColor], see
/// [Palette.validateColorName].
enum PaletteColorNameError {
  /// The name is not a valid Dart identifier, or its member would be a
  /// Dart keyword.
  invalid,

  /// Another color of the palette already uses the name.
  duplicate,
}

/// {@template palette_color}
/// A named color of a [Palette].
/// {@endtemplate}
class PaletteColor extends Equatable {
  /// {@macro palette_color}
  const new({required this.name, required this.color});

  /// The name of the color, which names its member in the generated code.
  final String name;

  /// The color as a 32 bit ARGB value.
  final int color;

  /// Returns a copy of this color with the given fields replaced.
  PaletteColor copyWith({String? name, int? color}) {
    return PaletteColor(name: name ?? this.name, color: color ?? this.color);
  }

  /// Converts this color to its JSON representation.
  Map<String, dynamic> toJson() => {'name': name, 'color': color};

  @override
  List<Object> get props => [name, color];
}

/// {@template palette}
/// The named colors of a project, shared by its components.
///
/// Its Dart code is a class with a constant for every color, which the
/// code of the components that use them references.
/// {@endtemplate}
class Palette extends Equatable {
  /// {@macro palette}
  const new({this.colors = const []});

  /// Creates a [Palette] from its JSON representation.
  ///
  /// Invalid entries are skipped, and so are names already taken.
  factory fromJson(Object? json) {
    final list = json is Map ? json['colors'] : null;
    final colors = <PaletteColor>[];
    if (list is List) {
      for (final entry in list) {
        if (entry case {'name': final String name, 'color': final int color}
            when Palette(colors: colors)
                    .validateColorName(colors.length, name) ==
                null) {
          colors.add(PaletteColor(name: name, color: color));
        }
      }
    }
    return Palette(colors: colors);
  }

  /// The colors, in the order they are shown and generated.
  final List<PaletteColor> colors;

  /// The value of the color called [name], or `null` if there is none.
  int? colorOf(String? name) {
    for (final color in colors) {
      if (color.name == name) return color.color;
    }
    return null;
  }

  /// Whether the palette has a color called [name].
  bool contains(String? name) => colorOf(name) != null;

  /// Checks whether [name] can be used for the color at [index] (which may
  /// be [colors]' length, for a new color).
  ///
  /// Returns `null` when it can. The name must be a valid Dart identifier
  /// whose member is not a keyword, and no other color may have the same
  /// member name (`main_color` and `mainColor` are both `mainColor`).
  PaletteColorNameError? validateColorName(int index, String name) {
    final member = dartMemberName(name);
    if (!isDartIdentifier(name) ||
        !isDartIdentifier(member) ||
        isDartKeyword(member)) {
      return PaletteColorNameError.invalid;
    }
    for (final (i, color) in colors.indexed) {
      if (i != index && dartMemberName(color.name) == member) {
        return PaletteColorNameError.duplicate;
      }
    }
    return null;
  }

  /// Whether every color has a valid name, see [validateColorName].
  bool get isValid {
    for (final (index, color) in colors.indexed) {
      if (validateColorName(index, color.name) != null) return false;
    }
    return true;
  }

  /// A name for a new color that no color uses yet: `color1`, `color2`…
  String uniqueColorName() {
    for (var i = 1; ; i++) {
      final name = 'color$i';
      if (validateColorName(colors.length, name) == null) return name;
    }
  }

  /// Returns a copy of this palette with [colors] replaced.
  Palette copyWith({List<PaletteColor>? colors}) {
    return Palette(colors: colors ?? this.colors);
  }

  /// Converts this palette to its JSON representation.
  Map<String, dynamic> toJson() => {
    'colors': [for (final color in colors) color.toJson()],
  };

  @override
  List<Object> get props => [colors];
}
