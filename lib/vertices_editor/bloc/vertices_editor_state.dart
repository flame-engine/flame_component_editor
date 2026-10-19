part of 'vertices_editor_cubit.dart';

/// The state of the [VerticesEditorCubit].
final class VerticesEditorState extends Equatable {
  /// Creates a [VerticesEditorState] editing [initial].
  new({
    required this.initial,
    List<ComponentVertex>? vertices,
    this.selectedIndex,
  }) : vertices = vertices ?? initial.vertices;

  /// The vertices the editor opened with.
  final ComponentVertices initial;

  /// The edited vertices, in order.
  final List<ComponentVertex> vertices;

  /// The index of the selected vertex in [vertices], if any.
  final int? selectedIndex;

  /// Whether a vertex can be deleted: a polygon needs at least
  /// [ComponentVertices.minLength] vertices.
  bool get canDelete => vertices.length > ComponentVertices.minLength;

  /// Whether the vertices were edited.
  bool get hasChanges => result != initial.normalized();

  /// The edited vertices, placed like Flame places them (see
  /// [ComponentVertices.normalized]).
  ComponentVertices get result => ComponentVertices(vertices).normalized();

  /// Returns a copy of this state with the given fields replaced.
  VerticesEditorState copyWith({
    List<ComponentVertex>? vertices,
    int? Function()? selectedIndex,
  }) {
    return VerticesEditorState(
      initial: initial,
      vertices: vertices ?? this.vertices,
      selectedIndex: selectedIndex != null
          ? selectedIndex()
          : this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [initial, vertices, selectedIndex];
}
