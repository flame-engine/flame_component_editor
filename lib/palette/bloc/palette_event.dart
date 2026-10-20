part of 'palette_bloc.dart';

/// An event of the [PaletteBloc].
sealed class PaletteEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// The palette dialog was opened.
final class PaletteStarted extends PaletteEvent {
  /// Creates a [PaletteStarted] event.
  const new();
}

/// The user added a color.
final class PaletteColorAdded extends PaletteEvent {
  /// Creates a [PaletteColorAdded] event.
  const new();
}

/// The user renamed the color of the entry with [id].
final class PaletteColorRenamed extends PaletteEvent {
  /// Creates a [PaletteColorRenamed] event.
  const new(this.id, this.name);

  /// The [PaletteEntry.id] of the color.
  final int id;

  /// The new name.
  final String name;

  @override
  List<Object> get props => [id, name];
}

/// The user changed the value of the color of the entry with [id].
final class PaletteColorValueChanged extends PaletteEvent {
  /// Creates a [PaletteColorValueChanged] event.
  const new(this.id, this.color);

  /// The [PaletteEntry.id] of the color.
  final int id;

  /// The new value, as a 32 bit ARGB value.
  final int color;

  @override
  List<Object> get props => [id, color];
}

/// The user removed the color of the entry with [id].
final class PaletteColorRemoved extends PaletteEvent {
  /// Creates a [PaletteColorRemoved] event.
  const new(this.id);

  /// The [PaletteEntry.id] of the color.
  final int id;

  @override
  List<Object> get props => [id];
}

/// The user asked to save the palette.
final class PaletteSaveRequested extends PaletteEvent {
  /// Creates a [PaletteSaveRequested] event.
  const new();
}
