import 'package:component_repository/component_repository.dart';

/// Navigates and edits the tree formed by a [Component] and its children.
///
/// A node of the tree is addressed by its path: the index of each child to
/// follow from the root. The root itself is the empty path.
extension ComponentTree on Component {
  /// Returns the node at [path].
  ///
  /// Throws a [RangeError] if there is no node at [path].
  Component nodeAt(List<int> path) {
    var node = this;
    for (final index in path) {
      node = node.children[index];
    }
    return node;
  }

  /// Whether there is a node at [path].
  bool hasNodeAt(List<int> path) {
    var node = this;
    for (final index in path) {
      if (index < 0 || index >= node.children.length) return false;
      node = node.children[index];
    }
    return true;
  }

  /// Returns a copy of this tree where the node at [path] is replaced by the
  /// result of [update].
  ///
  /// Throws a [RangeError] if there is no node at [path].
  Component updateNodeAt(
    List<int> path,
    Component Function(Component node) update,
  ) {
    if (path.isEmpty) return update(this);
    final [index, ...rest] = path;
    final children = [...this.children];
    children[index] = children[index].updateNodeAt(rest, update);
    return copyWithChildren(children);
  }

  /// Returns a copy of this tree with [child] added as the last child of the
  /// node at [path].
  Component addChildAt(List<int> path, Component child) {
    return updateNodeAt(
      path,
      (node) => node.copyWithChildren([...node.children, child]),
    );
  }

  /// Returns a copy of this tree without the node at [path].
  ///
  /// The root (the empty [path]) cannot be removed.
  Component removeNodeAt(List<int> path) {
    if (path.isEmpty) {
      throw ArgumentError.value(path, 'path', 'The root cannot be removed');
    }
    final parent = path.sublist(0, path.length - 1);
    return updateNodeAt(
      parent,
      (node) => node.copyWithChildren([...node.children]..removeAt(path.last)),
    );
  }

  /// This component followed by all of its descendants, depth first.
  Iterable<Component> get nodes sync* {
    yield this;
    for (final child in children) {
      yield* child.nodes;
    }
  }

  /// Returns a name for a new [type] node that no node of the tree uses
  /// yet, such as `rectangle1`.
  String uniqueChildName(ComponentType type) {
    final names = {for (final node in nodes) node.name};
    var index = 1;
    while (names.contains('${type.key}$index')) {
      index++;
    }
    return '${type.key}$index';
  }
}
