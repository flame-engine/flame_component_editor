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
/// Saving also generates the Dart code of the component in the output
/// folder of the project settings.
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
    required this._projectRepository,
  }) : super(
         ComponentEditorState(component: component, savedComponent: component),
       ) {
    on<ComponentEditorStarted>(_onStarted);
    on<ComponentEditorNodeSelected>(_onNodeSelected);
    on<ComponentEditorChildAdded>(_onChildAdded);
    on<ComponentEditorNodeRemoved>(_onNodeRemoved);
    on<ComponentEditorNameChanged>(_onNameChanged);
    on<ComponentEditorPositionChanged>(_onPositionChanged);
    on<ComponentEditorSizeChanged>(_onSizeChanged);
    on<ComponentEditorPaintChanged>(_onPaintChanged);
    on<ComponentEditorSaveRequested>(_onSaveRequested);
  }

  final Project _project;
  final ComponentRepository _componentRepository;
  final ProjectRepository _projectRepository;

  Future<void> _onStarted(
    ComponentEditorStarted event,
    Emitter<ComponentEditorState> emit,
  ) async {
    try {
      emit(state.copyWith(takenClassNames: await _loadTakenClassNames()));
    } on Exception {
      // Names are still validated inside the tree, and against the other
      // components when saving.
    }
  }

  /// The [ComponentTree.generatedClassNames] of the other components of
  /// the project.
  Future<Set<String>> _loadTakenClassNames() async {
    final components = await _componentRepository.getComponents(_project.path);
    final name = state.component.name;
    return {
      for (final other in components)
        if (other.name != name) ...other.generatedClassNames,
    };
  }

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
      component.uniqueChildName(
        event.type,
        takenClassNames: state.takenClassNames,
      ),
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

  void _onNameChanged(
    ComponentEditorNameChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    final path = state.selectedPath;
    if (path.isEmpty) return;
    final error = state.component.validateChildName(
      path,
      event.name,
      takenClassNames: state.takenClassNames,
    );
    if (error != null) return;
    _editSelected(emit, (node) => node.copyWithName(event.name));
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
    } on Exception {
      emit(state.copyWith(status: ComponentEditorStatus.failure));
      return;
    }

    // The component is saved even if its code can't be generated.
    var saved = state.copyWith(savedComponent: component);
    try {
      // Names are validated as they are typed, but the other components
      // may not have been loaded yet, or may have clashed already. Code
      // with clashing classes wouldn't compile, so it is not generated.
      final taken = await _loadTakenClassNames();
      saved = saved.copyWith(takenClassNames: taken);
      if (component.generatedClassNames.any(taken.contains)) {
        emit(saved.copyWith(status: ComponentEditorStatus.classConflict));
        return;
      }

      final settings = await _projectRepository.getSettings(_project);
      await _componentRepository.writeComponentCode(
        _project.path,
        settings.outputPath,
        component,
      );
      emit(saved.copyWith(status: ComponentEditorStatus.saved));
    } on GeneratedFileConflictException {
      emit(saved.copyWith(status: ComponentEditorStatus.codeConflict));
    } on Exception {
      emit(saved.copyWith(status: ComponentEditorStatus.codeFailure));
    }
  }
}
