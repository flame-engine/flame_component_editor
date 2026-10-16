import 'package:bloc_test/bloc_test.dart';
import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/project/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_repository/project_repository.dart';

class _MockComponentRepository extends Mock implements ComponentRepository;

void main() {
  group(ProjectBloc, () {
    const project = Project(path: '/projects/my_game');
    const player = Component(name: 'Player');
    const enemy = Component(name: 'Enemy');

    late ComponentRepository componentRepository;

    setUp(() {
      componentRepository = _MockComponentRepository();
    });

    ProjectBloc buildBloc() =>
        ProjectBloc(project: project, componentRepository: componentRepository);

    test('initial state is ProjectState', () {
      expect(buildBloc().state, equals(const ProjectState()));
    });

    group(ProjectComponentsRequested, () {
      blocTest<ProjectBloc, ProjectState>(
        'emits [loading, ready] with the components',
        setUp: () =>
            when(() => componentRepository.getComponents(project.path))
                .thenAnswer((_) async => [enemy, player]),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectComponentsRequested()),
        expect: () => const [
          ProjectState(status: ProjectStatus.loading),
          ProjectState(
            status: ProjectStatus.ready,
            components: [enemy, player],
          ),
        ],
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits [loading, failure] when loading fails',
        setUp: () =>
            when(() => componentRepository.getComponents(project.path))
                .thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectComponentsRequested()),
        expect: () => const [
          ProjectState(status: ProjectStatus.loading),
          ProjectState(status: ProjectStatus.failure),
        ],
      );
    });

    group(ProjectComponentCreateRequested, () {
      blocTest<ProjectBloc, ProjectState>(
        'emits created with the new component and reloaded components',
        setUp: () {
          when(
            () => componentRepository.createComponent(project.path, 'Player'),
          ).thenAnswer((_) async => player);
          when(() => componentRepository.getComponents(project.path))
              .thenAnswer((_) async => [player]);
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ProjectComponentCreateRequested('Player')),
        expect: () => const [
          ProjectState(
            status: ProjectStatus.created,
            components: [player],
            createdComponent: player,
          ),
        ],
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits invalidName when the name is invalid',
        setUp: () =>
            when(() => componentRepository.createComponent(project.path, '1'))
                .thenThrow(const InvalidComponentNameException('1')),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectComponentCreateRequested('1')),
        expect: () => const [ProjectState(status: ProjectStatus.invalidName)],
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits alreadyExists when the name is taken',
        setUp: () => when(
          () => componentRepository.createComponent(project.path, 'Player'),
        ).thenThrow(const ComponentAlreadyExistsException('Player')),
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ProjectComponentCreateRequested('Player')),
        expect: () => const [ProjectState(status: ProjectStatus.alreadyExists)],
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits failure when creating fails',
        setUp: () => when(
          () => componentRepository.createComponent(project.path, 'Player'),
        ).thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const ProjectComponentCreateRequested('Player')),
        expect: () => const [ProjectState(status: ProjectStatus.failure)],
      );
    });

    group(ProjectComponentDeleteRequested, () {
      blocTest<ProjectBloc, ProjectState>(
        'deletes the component and emits the reloaded components',
        setUp: () {
          when(() => componentRepository.deleteComponent(project.path, player))
              .thenAnswer((_) async {});
          when(() => componentRepository.getComponents(project.path))
              .thenAnswer((_) async => [enemy]);
        },
        build: buildBloc,
        seed: () => const ProjectState(
          status: ProjectStatus.ready,
          components: [enemy, player],
        ),
        act: (bloc) => bloc.add(const ProjectComponentDeleteRequested(player)),
        expect: () => const [
          ProjectState(status: ProjectStatus.ready, components: [enemy]),
        ],
        verify: (_) => verify(
          () => componentRepository.deleteComponent(project.path, player),
        ).called(1),
      );

      blocTest<ProjectBloc, ProjectState>(
        'emits failure when deleting fails',
        setUp: () => when(
          () => componentRepository.deleteComponent(project.path, player),
        ).thenThrow(Exception()),
        build: buildBloc,
        act: (bloc) => bloc.add(const ProjectComponentDeleteRequested(player)),
        expect: () => const [ProjectState(status: ProjectStatus.failure)],
      );
    });
  });
}
