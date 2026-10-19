import 'package:component_repository/component_repository.dart';
import 'package:flame/components.dart' as flame;
import 'package:flame/game.dart';
import 'package:flame_component_editor/component_editor/widgets/preview/flame_mapping.dart';
import 'package:flame_component_editor/component_editor/widgets/preview/selection_highlight.dart';
import 'package:flutter/painting.dart';

/// {@template component_preview_game}
/// A Flame game that renders a [Component] and its children, centered on
/// screen, and highlights one of them.
///
/// The game only renders: the component being edited is owned by the
/// `ComponentEditorBloc` and pushed here with [show].
/// {@endtemplate}
class ComponentPreviewGame extends FlameGame {
  /// {@macro component_preview_game}
  new({required this._component, this._highlightedPath});

  Component _component;
  List<int>? _highlightedPath;
  late flame.PositionComponent _preview;

  /// The Flame component currently rendering the previewed root
  /// [Component]. Its children render the [Component] children.
  flame.PositionComponent get preview => _preview;

  /// Draws the border around the highlighted node.
  final highlight = SelectionHighlight();

  @override
  Color backgroundColor() => const Color(0xFF1E1E1E);

  @override
  void onLoad() {
    world.add(highlight);
    _rebuild();
  }

  /// Renders [component] instead of the current one, highlighting the node
  /// at [highlightedPath] (see [ComponentTree]), if any.
  ///
  /// Only nodes with a size or a radius ([SizedComponent],
  /// [RadiusComponent]) are highlighted.
  ///
  /// The existing Flame components are updated in place, unless components
  /// were added, removed or changed type (see [haveSameShape]).
  void show(Component component, {List<int>? highlightedPath}) {
    final previous = _component;
    _component = component;
    _highlightedPath = highlightedPath;
    if (!isLoaded) return;
    if (haveSameShape(previous, component)) {
      applyTree(_preview, component);
      _updateHighlight();
    } else {
      _rebuild();
    }
  }

  void _rebuild() {
    if (isLoaded) _preview.removeFromParent();
    _preview = buildFlameComponent(_component);
    world.add(_preview);
    _updateHighlight();
  }

  void _updateHighlight() {
    final path = _highlightedPath;
    highlight.target =
        path != null &&
            _component.hasNodeAt(path) &&
            _hasBounds(_component.nodeAt(path))
        ? flameNodeAt(_preview, path)
        : null;
  }

  static bool _hasBounds(Component node) {
    return node is SizedComponent || node is RadiusComponent;
  }
}
