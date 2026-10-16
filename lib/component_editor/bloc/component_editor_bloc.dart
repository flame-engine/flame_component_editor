import 'package:bloc/bloc.dart';
import 'package:component_repository/component_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:project_repository/project_repository.dart';

part 'component_editor_event.dart';
part 'component_editor_state.dart';

/// {@template component_editor_bloc}
/// Edits the properties of a [Component] of a [Project] and saves it.
///
/// Property events are handled through the capability interfaces
/// ([SizedComponent], [PaintedComponent], ...), so they work for every
/// component type that has that property.
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
    on<ComponentEditorSizeChanged>(_onSizeChanged);
    on<ComponentEditorPaintChanged>(_onPaintChanged);
    on<ComponentEditorSaveRequested>(_onSaveRequested);
  }

  final Project _project;
  final ComponentRepository _componentRepository;

  void _onSizeChanged(
    ComponentEditorSizeChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    if (state.component case final SizedComponent component) {
      _edit(emit, component.copyWithSize(event.size));
    }
  }

  void _onPaintChanged(
    ComponentEditorPaintChanged event,
    Emitter<ComponentEditorState> emit,
  ) {
    if (state.component case final PaintedComponent component) {
      _edit(emit, component.copyWithPaint(event.paint));
    }
  }

  void _edit(Emitter<ComponentEditorState> emit, Component component) {
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
