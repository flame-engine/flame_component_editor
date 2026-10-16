import 'package:component_repository/component_repository.dart';
import 'package:flame/components.dart' as flame;
import 'package:flame/game.dart';
import 'package:flame_component_editor/component_editor/widgets/preview/flame_mapping.dart';
import 'package:flutter/painting.dart';

/// {@template component_preview_game}
/// A Flame game that renders a single [Component], centered on screen.
///
/// The game only renders: the component being edited is owned by the
/// `ComponentEditorBloc` and pushed here with [show].
/// {@endtemplate}
class ComponentPreviewGame extends FlameGame {
  /// {@macro component_preview_game}
  new({required this._component});

  Component _component;
  late flame.PositionComponent _preview;

  /// The Flame component currently rendering the previewed [Component].
  flame.PositionComponent get preview => _preview;

  @override
  Color backgroundColor() => const Color(0xFF1E1E1E);

  @override
  Future<void> onLoad() => _rebuild();

  /// Renders [component] instead of the current one.
  ///
  /// The existing Flame component is updated in place, unless [component]
  /// is of a different type.
  Future<void> show(Component component) async {
    final previous = _component;
    _component = component;
    if (!isLoaded) return;
    if (component.type != previous.type) {
      await _rebuild();
    } else {
      applyProperties(_preview, component);
    }
  }

  Future<void> _rebuild() async {
    if (isLoaded) _preview.removeFromParent();
    _preview = buildFlameComponent(_component);
    await world.add(_preview);
  }
}
