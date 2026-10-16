part of 'component_editor_bloc.dart';

/// The status of the [ComponentEditorBloc].
enum ComponentEditorStatus {
  /// The component can be edited.
  ready,

  /// The component is being saved.
  saving,

  /// The component was saved.
  saved,

  /// Something went wrong while saving.
  failure,
}

/// {@template component_editor_state}
/// The state of the [ComponentEditorBloc].
/// {@endtemplate}
final class ComponentEditorState extends Equatable {
  /// {@macro component_editor_state}
  const new({
    required this.component,
    required this.savedComponent,
    this.status = ComponentEditorStatus.ready,
    this.selectedPath = const [],
  });

  /// The current status.
  final ComponentEditorStatus status;

  /// The component being edited, including unsaved changes.
  final Component component;

  /// The component as it was last saved.
  final Component savedComponent;

  /// The path of the selected node of the [component] tree, see
  /// [ComponentTree]. The root, the empty path, is selected by default.
  final List<int> selectedPath;

  /// The selected node of the [component] tree.
  Component get selectedNode => component.nodeAt(selectedPath);

  /// Whether the selected node is the root [component].
  bool get isRootSelected => selectedPath.isEmpty;

  /// Whether [component] has changes that were not saved yet.
  bool get hasChanges => component != savedComponent;

  /// Returns a copy of this state with the given fields replaced.
  ComponentEditorState copyWith({
    ComponentEditorStatus? status,
    Component? component,
    Component? savedComponent,
    List<int>? selectedPath,
  }) {
    return ComponentEditorState(
      status: status ?? this.status,
      component: component ?? this.component,
      savedComponent: savedComponent ?? this.savedComponent,
      selectedPath: selectedPath ?? this.selectedPath,
    );
  }

  @override
  List<Object> get props => [status, component, savedComponent, selectedPath];
}
