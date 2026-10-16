import 'package:component_repository/component_repository.dart';
import 'package:flame/components.dart' as flame;
import 'package:flame/game.dart';
import 'package:flame_component_editor/component_editor/widgets/preview/flame_mapping.dart';
import 'package:flutter/painting.dart';

/// {@template component_preview_game}
/// A Flame game that renders a [Component] and its children, centered on
/// screen.
///
/// The game only renders: the component being edited is owned by the
/// `ComponentEditorBloc` and pushed here with [show].
/// {@endtemplate}
class ComponentPreviewGame extends FlameGame {
  /// {@macro component_preview_game}
  new({required this._component});

  Component _component;
  late flame.PositionComponent _preview;

  /// The Flame component currently rendering the previewed root
  /// [Component]. Its children render the [Component] children.
  flame.PositionComponent get preview => _preview;

  @override
  Color backgroundColor() => const Color(0xFF1E1E1E);

  @override
  void onLoad() => _rebuild();

  /// Renders [component] instead of the current one.
  ///
  /// The existing Flame components are updated in place, unless components
  /// were added, removed or changed type (see [haveSameShape]).
  void show(Component component) {
    final previous = _component;
    _component = component;
    if (!isLoaded) return;
    if (haveSameShape(previous, component)) {
      applyTree(_preview, component);
    } else {
      _rebuild();
    }
  }

  void _rebuild() {
    if (isLoaded) _preview.removeFromParent();
    _preview = buildFlameComponent(_component);
    world.add(_preview);
  }
}
