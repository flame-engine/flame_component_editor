import 'package:bloc/bloc.dart';
import 'package:component_repository/component_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:project_repository/project_repository.dart';

part 'project_event.dart';
part 'project_state.dart';

/// {@template project_bloc}
/// Lists, creates and deletes the components of an open [Project].
/// {@endtemplate}
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  /// {@macro project_bloc}
  new({required this._project, required this._componentRepository})
    : super(const ProjectState()) {
    on<ProjectComponentsRequested>(_onComponentsRequested);
    on<ProjectComponentCreateRequested>(_onComponentCreateRequested);
    on<ProjectComponentDeleteRequested>(_onComponentDeleteRequested);
  }

  final Project _project;
  final ComponentRepository _componentRepository;

  Future<void> _onComponentsRequested(
    ProjectComponentsRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    try {
      emit(
        state.copyWith(
          status: ProjectStatus.ready,
          components: await _getComponents(),
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ProjectStatus.failure));
    }
  }

  Future<void> _onComponentCreateRequested(
    ProjectComponentCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final component = await _componentRepository.createComponent(
        _project.path,
        event.name,
        event.type,
      );
      emit(
        state.copyWith(
          status: ProjectStatus.created,
          createdComponent: component,
          components: await _getComponents(),
        ),
      );
    } on InvalidComponentNameException {
      emit(state.copyWith(status: ProjectStatus.invalidName));
    } on ComponentAlreadyExistsException {
      emit(state.copyWith(status: ProjectStatus.alreadyExists));
    } on Exception {
      emit(state.copyWith(status: ProjectStatus.failure));
    }
  }

  Future<void> _onComponentDeleteRequested(
    ProjectComponentDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _componentRepository.deleteComponent(
        _project.path,
        event.component,
      );
      emit(
        state.copyWith(
          status: ProjectStatus.ready,
          components: await _getComponents(),
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ProjectStatus.failure));
    }
  }

  Future<List<Component>> _getComponents() =>
      _componentRepository.getComponents(_project.path);
}
