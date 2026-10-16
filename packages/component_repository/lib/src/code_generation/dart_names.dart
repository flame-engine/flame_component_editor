import 'package:component_repository/component_repository.dart';

final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

/// Whether [name] is a valid Dart identifier.
bool isDartIdentifier(String name) => _identifier.hasMatch(name);

/// The name of the class generated for a component called [name]:
/// `player_ship` and `playerShip` become `PlayerShip`.
String dartClassName(String name) {
  return [
    for (final word in name.split('_'))
      if (word.isNotEmpty) word[0].toUpperCase() + word.substring(1),
  ].join();
}

/// The name of the class generated for a root component called [name],
/// with the `$` prefix of generated code: `player_ship` becomes
/// `$PlayerShip`.
///
/// The prefix keeps generated classes from clashing with the classes of
/// the game (or Flame's), which can subclass them.
String dartRootClassName(String name) => '\$${dartClassName(name)}';

/// The name of the class generated for a child component called
/// [childName] of the root component called [rootName]: the `head` of
/// `player_ship` becomes `$PlayerShipHead`.
///
/// Only children that have children of their own get a class.
String dartChildClassName(String rootName, String childName) {
  return '${dartRootClassName(rootName)}${dartClassName(childName)}';
}

/// The name of the getter generated for a child component called [name]:
/// `left_arm` and `LeftArm` become `leftArm`.
String dartMemberName(String name) {
  final className = dartClassName(name);
  if (className.isEmpty) return className;
  return className[0].toLowerCase() + className.substring(1);
}

/// The name, without extension, of the file generated for a component
/// called [name]: `PlayerShip` and `playerShip` become `player_ship`.
String dartFileName(String name) {
  return name
      .replaceAllMapped(
        RegExp('([a-z0-9])([A-Z])'),
        (match) => '${match[1]}_${match[2]}',
      )
      .toLowerCase()
      .split('_')
      .where((word) => word.isNotEmpty)
      .join('_');
}

/// Whether [name] is a Dart keyword, which can't be used as a member name.
bool isDartKeyword(String name) => _keywords.contains(name);

/// The names of the members a generated class inherits from the Flame class
/// of [type]. Getters of children must not use them.
Set<String> flameMemberNames(ComponentType type) {
  return switch (type) {
    ComponentType.rectangle => _rectangleComponentMembers,
  };
}

const _keywords = {
  // Reserved words.
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue',
  'default', 'do', 'else', 'enum', 'extends', 'false', 'final', 'finally',
  'for', 'if', 'in', 'is', 'new', 'null', 'rethrow', 'return', 'super',
  'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',
  // Built-in identifiers and contextual keywords.
  'abstract', 'as', 'async', 'await', 'base', 'covariant', 'deferred',
  'dynamic', 'export', 'extension', 'external', 'factory', 'get', 'hide',
  'implements', 'import', 'interface', 'late', 'library', 'mixin', 'of',
  'on', 'operator', 'part', 'required', 'sealed', 'set', 'show', 'static',
  'sync', 'typedef', 'when', 'yield',
};

/// Public members of Flame's `RectangleComponent` (Flame 2.0.0-dev.1),
/// including the inherited ones.
const _rectangleComponentMembers = {
  'absoluteAngle',
  'absoluteAngleWithoutReflection',
  'absoluteCenter',
  'absolutePosition',
  'absolutePositionOf',
  'absolutePositionOfAnchor',
  'absoluteScale',
  'absoluteScaledSize',
  'absoluteToLocal',
  'absoluteTopLeftPosition',
  'add',
  'addAll',
  'addToParent',
  'afterChildrenRendered',
  'ancestors',
  'anchor',
  'angle',
  'angleTo',
  'center',
  'children',
  'componentsAtLocation',
  'componentsAtPoint',
  'contains',
  'containsLocalPoint',
  'containsPoint',
  'createComponentList',
  'debugColor',
  'debugCoordinatesPrecision',
  'debugMode',
  'debugPaint',
  'debugTextPaint',
  'decorator',
  'deletePaint',
  'descendants',
  'distance',
  'findGame',
  'findParent',
  'findRenderContext',
  'findRootGame',
  'firstChild',
  'flipHorizontally',
  'flipHorizontallyAroundCenter',
  'flipVertically',
  'flipVerticallyAroundCenter',
  'getAlpha',
  'getEdge',
  'getOpacity',
  'getPaint',
  'getVertex',
  'globalVertices',
  'handleHotReload',
  'handleResize',
  'hasChildren',
  'hasPaintLayers',
  'hashCode',
  'height',
  'hue',
  'isFlippedHorizontally',
  'isFlippedVertically',
  'isLoaded',
  'isLoading',
  'isMounted',
  'isMounting',
  'isRemoved',
  'isRemoving',
  'isSolid',
  'key',
  'lastChild',
  'loadSettled',
  'loaded',
  'localToParent',
  'lookAt',
  'makeOpaque',
  'makeTransparent',
  'manuallyPositioned',
  'mounted',
  'nativeAngle',
  'noSuchMethod',
  'onChanged',
  'onChildrenChanged',
  'onGameResize',
  'onHotReload',
  'onLoad',
  'onMount',
  'onParentResize',
  'onRemove',
  'opacity',
  'opacityProviderOf',
  'opacityProviderOfList',
  'paint',
  'paintLayers',
  'paintLayersInternal',
  'parent',
  'parentToLocal',
  'position',
  'positionOf',
  'positionOfAnchor',
  'possibleIntersectionVertices',
  'priority',
  'propagateToChildren',
  'rebalanceChildren',
  'refreshVertices',
  'remove',
  'removeAll',
  'removeFromParent',
  'removeWhere',
  'removed',
  'render',
  'renderChild',
  'renderContext',
  'renderDebugMode',
  'renderShape',
  'renderTree',
  'renderTreeWithoutDecorator',
  'runtimeType',
  'scale',
  'scaledSize',
  'setAlpha',
  'setByRect',
  'setColor',
  'setLoaded',
  'setMounted',
  'setOpacity',
  'setPaint',
  'setRemoved',
  'shrinkToBounds',
  'size',
  'tint',
  'toAbsoluteRect',
  'toLocal',
  'toRect',
  'toString',
  'topLeftPosition',
  'transform',
  'transformMatrix',
  'update',
  'updateTree',
  'vertices',
  'width',
  'x',
  'y',
};
