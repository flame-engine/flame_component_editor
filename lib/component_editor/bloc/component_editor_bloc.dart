import 'package:bloc/bloc.dart';
import 'package:component_repository/component_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:project_repository/project_repository.dart';

part 'component_editor_event.dart';
part 'component_editor_state.dart';

/// {@template component_editor_bloc}
/// Edits a [Component] of a [Project], including the tree of components
/// inside it, and saves it.
///
/// Property events edit the selected node of the tree (the root by
/// default). They are handled through the capability interfaces
/// ([PositionedComponent], [SizedComponent], [PaintedComponent], ...), so
/// they work for every component type that has that property.
/// {@endtemplate}
class ComponentEditorBloc
    extends Bloc<ComponentEditorEvent, ComponentEditorState> {
  /// {@macro component_editor_bloc}
  new({
    required this._project,
    required Component component,
    required this._componentRepository,
  }) : super(
         ComponentEditorState(component: component, savedComponent: component),
       ) {
    on<ComponentEditorNodeSelected>(_onNodeSelected);
    on<ComponentEditorChildAdded>(_onChildAdded);
    on<ComponentEditorNodeRemoved>(_onNodeRemoved);
    on<ComponentEditorPositionChanged>(_onPositionChanged);
    on<ComponentEditorSizeChanged>(_onSizeChanged);
    on<ComponentEditorPaintChanged>(_onPaintChanged);
    on<ComponentEditorSaveRequested>(_onSaveRequested);
  }

  final Project _project;
  final ComponentRepository _componentRepository;

  void _onNodeSelected(
    ComponentEditorNodeSelected event,
    Emitter<ComponentEditorState> emit,
  ) {
    if (!state.component.hasNodeAt(event.path)) return;
    emit(state.copyWith(selectedPath: event.path));
  }

  void _onChildAdded(
    ComponentEditorChildAdded event,
    Emitter<ComponentEditorState> emit,
  ) {
    final component = state.component;
    final parentPath = state.selectedPath;
    final child = Component.create(
      component.uniqueChildName(event.type),
      event.type,
    );
    emit(
      state.copyWith(
        status: ComponentEditorStatus.ready,
        component: component.addChildAt(parentPath, child),
        selectedPath: [
          ...parentPath,
          component.nodeAt(parentPath).children.length,
        ],
      ),
    );
  }

  void _onNodeRemoved(
    ComponentEditorNodeRemoved event,
    Emitter<ComponentEditorState> emit,
  ) {
    final path = event.path;
    if (path.isEmpty || !state.component.hasNodeAt(path)) return;
    emit(
      state.copyWith(
        status: ComponentEditorStatus.ready,
        component: state.component.removeNodeAt(path),
        selectedPath: path.sublist(0, path.length - 1),
      ),
    );
  }

  void _onPositionChanged(
    ComponentEditorPositionChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final PositionedComponent node) {
        return node.copyWithPosition(event.position);
      }
      return node;
    });
  }

  void _onSizeChanged(
    ComponentEditorSizeChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final SizedComponent node) {
        return node.copyWithSize(event.size);
      }
      return node;
    });
  }

  void _onPaintChanged(
    ComponentEditorPaintChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    _editSelected(emit, (node) {
      if (node case final PaintedComponent node) {
        return node.copyWithPaint(event.paint);
      }
      return node;
    });
  }

  /// Replaces the selected node with the result of [edit].
  void _editSelected(
    Emitter<ComponentEditorState> emit,
    Component Function(Component node) edit,
  ) {
    final component = state.component.updateNodeAt(state.selectedPath, edit);
    if (component == state.component) return;
    emit(
      state.copyWith(status: ComponentEditorStatus.ready, component: component),
    );
  }

  Future<void> _onSaveRequested(
    ComponentEditorSaveRequested event,
    Emitter<ComponentEditorState> emit,
  ) async {
    if (!state.hasChanges) return;
    final component = state.component;
    emit(state.copyWith(status: ComponentEditorStatus.saving));
    try {
      await _componentRepository.saveComponent(_project.path, component);
      emit(
        state.copyWith(
          status: ComponentEditorStatus.saved,
          savedComponent: component,
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ComponentEditorStatus.failure));
    }
  }
}
