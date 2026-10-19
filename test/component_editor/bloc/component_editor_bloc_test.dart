import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/component_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_repository/project_repository.dart';

class _MockComponentRepository extends Mock implements ComponentRepository;

class _MockProjectRepository extends Mock implements ProjectRepository;

void main() {
  setUpAll(
    () => registerFallbackValue(const RectangleComponent(name: 'Fallback')),
  );

  group(ComponentEditorBloc, () {
    const project = Project(path: '/projects/my_game');
    const component = RectangleComponent(name: 'Player');
    const size = ComponentSize(width: 10, height: 20);
    const paint = ComponentPaint(color: 0xFFFF0000, style: PaintStyle.stroke);
    const edited = RectangleComponent(name: 'Player', size: size);

    late ComponentRepository componentRepository;
    late ProjectRepository projectRepository;

    setUp(() {
      componentRepository = _MockComponentRepository();
      projectRepository = _MockProjectRepository();
      when(
        () => projectRepository.getSettings(project),
      ).thenAnswer((_) async => const ProjectSettings(outputPath: 'lib/game'));
    });

    ComponentEditorBloc buildBloc() => ComponentEditorBloc(
      project: project,
      component: component,
      componentRepository: componentRepository,
      projectRepository: projectRepository,
    );

    test('initial state has no changes', () {
      final state = buildBloc().state;

      expect(
        state,
        equals(
          const ComponentEditorState(
            component: component,
            savedComponent: component,
          ),
        ),
      );
      expect(state.hasChanges, isFalse);
    });

    blocTest<ComponentEditorBloc, ComponentEditorState>(
      'ComponentEditorSizeChanged updates the size',
      build: buildBloc,
      act: (bloc) => bloc.add(const ComponentEditorSizeChanged(size)),
      expect: () => [
        isA<ComponentEditorState>()
            .having((s) => s.component, 'component', edited)
            .having((s) => s.hasChanges, 'hasChanges', isTrue),
      ],
    );

    blocTest<ComponentEditorBloc, ComponentEditorState>(
      'ComponentEditorAnchorChanged updates the anchor',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ComponentEditorAnchorChanged(ComponentAnchor.center)),
      expect: () => const [
        ComponentEditorState(
          component: RectangleComponent(
            name: 'Player',
            anchor: ComponentAnchor.center,
          ),
          savedComponent: component,
        ),
      ],
    );

    blocTest<ComponentEditorBloc, ComponentEditorState>(
      'ComponentEditorAngleChanged updates the angle',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const ComponentEditorAngleChanged(ComponentAngle(radians: 1)),
      ),
      expect: () => const [
        ComponentEditorState(
          component: RectangleComponent(
            name: 'Player',
            angle: ComponentAngle(radians: 1),
          ),
          savedComponent: component,
        ),
      ],
    );

    group('ComponentEditorVerticesChanged', () {
      const vertices = ComponentVertices(ComponentVertices.square);
      const polygon = PolygonComponent(name: 'Player');

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'updates the vertices of a polygon',
        build: () => ComponentEditorBloc(
          project: project,
          component: polygon,
          componentRepository: componentRepository,
          projectRepository: projectRepository,
        ),
        act: (bloc) => bloc.add(const ComponentEditorVerticesChanged(vertices)),
        expect: () => const [
          ComponentEditorState(
            component: PolygonComponent(name: 'Player', vertices: vertices),
            savedComponent: polygon,
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ignores components without vertices',
        build: buildBloc,
        act: (bloc) => bloc.add(const ComponentEditorVerticesChanged(vertices)),
        expect: () => const <ComponentEditorState>[],
      );
    });

    group('ComponentEditorRadiusChanged', () {
      const radius = ComponentRadius(radius: 10);
      const circle = CircleComponent(name: 'Player');

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'updates the radius of a circle',
        build: () => ComponentEditorBloc(
          project: project,
          component: circle,
          componentRepository: componentRepository,
          projectRepository: projectRepository,
        ),
        act: (bloc) => bloc.add(const ComponentEditorRadiusChanged(radius)),
        expect: () => const [
          ComponentEditorState(
            component: CircleComponent(name: 'Player', radius: radius),
            savedComponent: circle,
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ignores components without a radius',
        build: buildBloc,
        act: (bloc) => bloc.add(const ComponentEditorRadiusChanged(radius)),
        expect: () => const <ComponentEditorState>[],
      );
    });

    blocTest<ComponentEditorBloc, ComponentEditorState>(
      'ComponentEditorPaintChanged updates the paint',
      build: buildBloc,
      act: (bloc) => bloc.add(const ComponentEditorPaintChanged(paint)),
      expect: () => const [
        ComponentEditorState(
          component: RectangleComponent(name: 'Player', paint: paint),
          savedComponent: component,
        ),
      ],
    );

    test('highlights the selection by default', () {
      expect(buildBloc().state.isSelectionHighlighted, isTrue);
    });

    blocTest<ComponentEditorBloc, ComponentEditorState>(
      'ComponentEditorSelectionHighlightToggled toggles the highlight',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const ComponentEditorSelectionHighlightToggled())
        ..add(const ComponentEditorSelectionHighlightToggled()),
      expect: () => const [
        ComponentEditorState(
          component: component,
          savedComponent: component,
          isSelectionHighlighted: false,
        ),
        ComponentEditorState(component: component, savedComponent: component),
      ],
    );

    test('rootClassOwner is the other component generating the root '
        'class', () {
      const aB = RectangleComponent(name: 'a_b');
      const aBHead = RectangleComponent(name: 'a_b_head');
      const state = ComponentEditorState(
        component: RectangleComponent(
          name: 'AB',
          children: [RectangleComponent(name: 'head')],
        ),
        savedComponent: component,
        takenClassNames: {r'$AB': aB, r'$ABHead': aBHead, r'$X': aB},
      );

      expect(state.rootClassOwner, equals(aB));
      expect(
        state.conflictingClassNames,
        equals({r'$AB': aB, r'$ABHead': aBHead}),
      );
    });

    group(ComponentEditorStarted, () {
      const enemy = RectangleComponent(name: 'Enemy');
      const ship = RectangleComponent(
        name: 'Ship',
        children: [RectangleComponent(name: 'wing')],
      );

      void stubComponents(List<Component> components) {
        when(() => componentRepository.getComponents(project.path))
            .thenAnswer((_) async => components);
      }

      void stubUpToDate({required bool isUpToDate}) {
        when(
          () => componentRepository.isComponentCodeUpToDate(
            project.path,
            'lib/game',
            component,
          ),
        ).thenAnswer((_) async => isUpToDate);
      }

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'loads the classes of the other components',
        setUp: () {
          stubComponents(const [enemy, component, ship]);
          stubUpToDate(isUpToDate: true);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ComponentEditorStarted()),
        expect: () => const [
          ComponentEditorState(
            component: component,
            savedComponent: component,
            takenClassNames: {
              r'$Enemy': enemy,
              r'$Ship': ship,
              r'$ShipWing': ship,
            },
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'reports clashes that already exist',
        setUp: () {
          stubComponents(const [RectangleComponent(name: 'player_')]);
          stubUpToDate(isUpToDate: true);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ComponentEditorStarted()),
        skip: 1,
        expect: () => [
          isA<ComponentEditorState>()
              .having(
                (s) => s.status,
                'status',
                ComponentEditorStatus.classConflict,
              )
              .having(
                (s) => s.rootClassOwner?.name,
                'rootClassOwner',
                'player_',
              ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'marks missing or outdated code, so it can be saved without changes',
        setUp: () {
          stubComponents(const []);
          stubUpToDate(isUpToDate: false);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ComponentEditorStarted()),
        // The other components are loaded first.
        skip: 1,
        expect: () => [
          isA<ComponentEditorState>()
              .having((s) => s.isCodeOutdated, 'isCodeOutdated', isTrue)
              .having((s) => s.canSave, 'canSave', isTrue),
        ],
      );

      test('does not overwrite what a save found meanwhile', () async {
        stubComponents(const []);
        final isUpToDate = Completer<bool>();
        when(
          () => componentRepository.isComponentCodeUpToDate(
            project.path,
            'lib/game',
            component,
          ),
        ).thenAnswer((_) => isUpToDate.future);
        when(() => componentRepository.saveComponent(project.path, edited))
            .thenAnswer((_) async {});
        when(
          () => componentRepository.writeComponentCode(
            project.path,
            'lib/game',
            edited,
          ),
        ).thenAnswer((_) async {});

        final bloc = buildBloc()..add(const ComponentEditorStarted());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(const ComponentEditorSizeChanged(size))
          ..add(const ComponentEditorSaveRequested());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.status, ComponentEditorStatus.saved);

        // The check was for the code of the component before the save.
        isUpToDate.complete(false);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.isCodeOutdated, isFalse);
        await bloc.close();
      });

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'emits nothing when nothing can be loaded',
        setUp: () {
          when(() => componentRepository.getComponents(project.path))
              .thenThrow(Exception());
          when(() => projectRepository.getSettings(project))
              .thenThrow(Exception());
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ComponentEditorStarted()),
        expect: () => const <ComponentEditorState>[],
      );
    });

    group('component tree', () {
      const child = RectangleComponent(name: 'rectangle1');
      const tree = RectangleComponent(name: 'Player', children: [child]);
      const treeState = ComponentEditorState(
        component: tree,
        savedComponent: tree,
      );

      test('selects the root by default', () {
        final state = buildBloc().state;

        expect(state.selectedPath, isEmpty);
        expect(state.isRootSelected, isTrue);
        expect(state.selectedNode, equals(component));
      });

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ComponentEditorNodeSelected selects the node',
        build: buildBloc,
        seed: () => treeState,
        act: (bloc) => bloc.add(const ComponentEditorNodeSelected([0])),
        expect: () => [
          isA<ComponentEditorState>()
              .having((s) => s.selectedPath, 'selectedPath', [0])
              .having((s) => s.selectedNode, 'selectedNode', child)
              .having((s) => s.hasChanges, 'hasChanges', isFalse),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ComponentEditorNodeSelected ignores paths that do not exist',
        build: buildBloc,
        seed: () => treeState,
        act: (bloc) => bloc.add(const ComponentEditorNodeSelected([3])),
        expect: () => const <ComponentEditorState>[],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ComponentEditorChildAdded adds a child to the selected node and '
        'selects it',
        build: buildBloc,
        seed: () => treeState.copyWith(selectedPath: [0]),
        act: (bloc) =>
            bloc.add(const ComponentEditorChildAdded(ComponentType.rectangle)),
        expect: () => const [
          ComponentEditorState(
            component: RectangleComponent(
              name: 'Player',
              children: [
                RectangleComponent(
                  name: 'rectangle1',
                  children: [RectangleComponent(name: 'rectangle2')],
                ),
              ],
            ),
            savedComponent: tree,
            selectedPath: [0, 0],
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ComponentEditorChildAdded adds polygons with the picked shape',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ComponentEditorChildAdded(
            ComponentType.polygon,
            polygonShape: PolygonShape.square,
          ),
        ),
        expect: () => [
          isA<ComponentEditorState>().having(
            (s) => s.selectedNode,
            'selectedNode',
            const PolygonComponent(
              name: 'polygon1',
              vertices: ComponentVertices(ComponentVertices.square),
            ),
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ComponentEditorChildAdded skips names whose class is taken',
        build: buildBloc,
        seed: () => const ComponentEditorState(
          component: component,
          savedComponent: component,
          takenClassNames: {
            r'$PlayerRectangle1': RectangleComponent(name: 'player_rectangle1'),
          },
        ),
        act: (bloc) =>
            bloc.add(const ComponentEditorChildAdded(ComponentType.rectangle)),
        expect: () => [
          isA<ComponentEditorState>().having(
            (s) => s.selectedNode.name,
            'selectedNode.name',
            'rectangle2',
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ComponentEditorNodeRemoved removes the node and selects its parent',
        build: buildBloc,
        seed: () => treeState.copyWith(selectedPath: [0]),
        act: (bloc) => bloc.add(const ComponentEditorNodeRemoved([0])),
        expect: () => const [
          ComponentEditorState(
            component: RectangleComponent(name: 'Player'),
            savedComponent: tree,
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ComponentEditorNodeRemoved never removes the root',
        build: buildBloc,
        seed: () => treeState,
        act: (bloc) => bloc.add(const ComponentEditorNodeRemoved([])),
        expect: () => const <ComponentEditorState>[],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'property changes edit the selected node',
        build: buildBloc,
        seed: () => treeState.copyWith(selectedPath: [0]),
        act: (bloc) => bloc
          ..add(const ComponentEditorPositionChanged(ComponentPosition(x: 5)))
          ..add(const ComponentEditorSizeChanged(size))
          ..add(const ComponentEditorPaintChanged(paint)),
        skip: 2,
        expect: () => const [
          ComponentEditorState(
            component: RectangleComponent(
              name: 'Player',
              children: [
                RectangleComponent(
                  name: 'rectangle1',
                  position: ComponentPosition(x: 5),
                  size: size,
                  paint: paint,
                ),
              ],
            ),
            savedComponent: tree,
            selectedPath: [0],
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'property changes that change nothing emit nothing',
        build: buildBloc,
        seed: () => treeState,
        act: (bloc) =>
            bloc.add(const ComponentEditorSizeChanged(ComponentSize())),
        expect: () => const <ComponentEditorState>[],
      );
    });

    group(ComponentEditorSaveRequested, () {
      const playerHead = RectangleComponent(name: 'player_head');

      setUp(
        () =>
            when(() => componentRepository.getComponents(project.path))
                .thenAnswer((_) async => const [component]),
      );

      void stubSave() {
        when(() => componentRepository.saveComponent(project.path, edited))
            .thenAnswer((_) async {});
      }

      void stubCode(Future<void> Function(Invocation) answer) {
        when(
          () => componentRepository.writeComponentCode(
            project.path,
            'lib/game',
            edited,
          ),
        ).thenAnswer(answer);
      }

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'saves the component, generates its code and clears the changes',
        setUp: () {
          stubSave();
          stubCode((_) async {});
        },
        build: buildBloc,
        seed: () => const ComponentEditorState(
          component: edited,
          savedComponent: component,
        ),
        act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
        expect: () => const [
          ComponentEditorState(
            status: ComponentEditorStatus.saving,
            component: edited,
            savedComponent: component,
          ),
          ComponentEditorState(
            status: ComponentEditorStatus.saved,
            component: edited,
            savedComponent: edited,
          ),
        ],
        verify: (_) {
          verify(() => componentRepository.saveComponent(project.path, edited))
              .called(1);
          verify(
            () => componentRepository.writeComponentCode(
              project.path,
              'lib/game',
              edited,
            ),
          ).called(1);
        },
      );

      for (final (exception, status) in [
        (
          const GeneratedFileConflictException('/projects/my_game/x.dart'),
          ComponentEditorStatus.codeConflict,
        ),
        (Exception(), ComponentEditorStatus.codeFailure),
      ]) {
        blocTest<ComponentEditorBloc, ComponentEditorState>(
          'emits $status, with the changes saved, when generating the code '
          'throws ${exception.runtimeType}',
          setUp: () {
            stubSave();
            stubCode((_) async => throw exception);
          },
          build: buildBloc,
          seed: () => const ComponentEditorState(
            component: edited,
            savedComponent: component,
          ),
          act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
          expect: () => [
            const ComponentEditorState(
              status: ComponentEditorStatus.saving,
              component: edited,
              savedComponent: component,
            ),
            ComponentEditorState(
              status: status,
              component: edited,
              savedComponent: edited,
              isCodeOutdated: true,
            ),
          ],
        );
      }

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'emits classConflict, and saves nothing, when another component '
        'generates one of its classes',
        setUp: () =>
            when(() => componentRepository.getComponents(project.path))
                .thenAnswer((_) async => const [component, playerHead]),
        build: buildBloc,
        // The other components were not loaded when the child was named.
        seed: () => const ComponentEditorState(
          component: RectangleComponent(
            name: 'Player',
            children: [RectangleComponent(name: 'head')],
          ),
          savedComponent: component,
        ),
        act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
        skip: 1,
        expect: () => [
          isA<ComponentEditorState>()
              .having(
                (s) => s.status,
                'status',
                ComponentEditorStatus.classConflict,
              )
              .having((s) => s.hasChanges, 'hasChanges', isTrue)
              .having((s) => s.canSave, 'canSave', isTrue)
              .having((s) => s.conflictingClassNames, 'conflictingClassNames', {
                r'$PlayerHead': playerHead,
              })
              .having((s) => s.rootClassOwner, 'rootClassOwner', isNull),
        ],
        verify: (_) {
          verifyNever(() => componentRepository.saveComponent(any(), any()));
          verifyNever(
            () => componentRepository.writeComponentCode(any(), any(), any()),
          );
        },
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'emits failure when the other components cannot be loaded',
        setUp: () =>
            when(() => componentRepository.getComponents(project.path))
                .thenThrow(Exception()),
        build: buildBloc,
        seed: () => const ComponentEditorState(
          component: edited,
          savedComponent: component,
        ),
        act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
        skip: 1,
        expect: () => const [
          ComponentEditorState(
            status: ComponentEditorStatus.failure,
            component: edited,
            savedComponent: component,
          ),
        ],
        verify: (_) =>
            verifyNever(() => componentRepository.saveComponent(any(), any())),
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'edits made while saving keep saving, so no other save starts',
        setUp: () {
          stubSave();
          stubCode((_) async {});
        },
        build: buildBloc,
        seed: () => const ComponentEditorState(
          component: edited,
          savedComponent: component,
        ),
        act: (bloc) => bloc
          ..add(const ComponentEditorSaveRequested())
          ..add(const ComponentEditorPaintChanged(paint))
          ..add(const ComponentEditorSaveRequested()),
        wait: Duration.zero,
        verify: (bloc) {
          verify(() => componentRepository.saveComponent(project.path, any()))
              .called(1);
          expect(bloc.state.status, ComponentEditorStatus.saved);
          expect(bloc.state.hasChanges, isTrue);
        },
      );

      test('goes back to ready when the clashing child is renamed while '
          'loading', () async {
        final components = Completer<List<Component>>();
        when(() => componentRepository.getComponents(project.path))
            .thenAnswer((_) => components.future);
        const tree = RectangleComponent(
          name: 'Player',
          children: [RectangleComponent(name: 'head')],
        );
        final bloc = buildBloc()
          ..emit(
            const ComponentEditorState(
              component: tree,
              savedComponent: component,
              selectedPath: [0],
            ),
          )
          ..add(const ComponentEditorSaveRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ComponentEditorNameChanged('eye'));
        await Future<void>.delayed(Duration.zero);
        components.complete(const [playerHead]);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, ComponentEditorStatus.ready);
        expect(bloc.state.selectedNode.name, 'eye');
        verifyNever(() => componentRepository.saveComponent(any(), any()));
        await bloc.close();
      });

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'keeps edits made while saving',
        setUp: () {
          stubSave();
          stubCode((_) async {});
        },
        build: buildBloc,
        seed: () => const ComponentEditorState(
          component: edited,
          savedComponent: component,
        ),
        act: (bloc) => bloc
          ..add(const ComponentEditorSaveRequested())
          ..add(const ComponentEditorPaintChanged(paint)),
        wait: Duration.zero,
        skip: 2,
        expect: () => [
          isA<ComponentEditorState>()
              .having((s) => s.status, 'status', ComponentEditorStatus.saved)
              .having((s) => s.savedComponent, 'savedComponent', edited)
              .having(
                (s) => s.component,
                'component',
                const RectangleComponent(
                  name: 'Player',
                  size: size,
                  paint: paint,
                ),
              )
              .having((s) => s.hasChanges, 'hasChanges', isTrue),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'emits failure when saving fails',
        setUp: () =>
            when(() => componentRepository.saveComponent(project.path, edited))
                .thenThrow(Exception()),
        build: buildBloc,
        seed: () => const ComponentEditorState(
          component: edited,
          savedComponent: component,
        ),
        act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
        expect: () => const [
          ComponentEditorState(
            status: ComponentEditorStatus.saving,
            component: edited,
            savedComponent: component,
          ),
          ComponentEditorState(
            status: ComponentEditorStatus.failure,
            component: edited,
            savedComponent: component,
          ),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'saves again without changes to generate outdated code',
        setUp: () {
          stubSave();
          stubCode((_) async {});
        },
        build: buildBloc,
        seed: () => const ComponentEditorState(
          status: ComponentEditorStatus.classConflict,
          component: edited,
          savedComponent: edited,
          isCodeOutdated: true,
        ),
        act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
        skip: 1,
        expect: () => const [
          ComponentEditorState(
            status: ComponentEditorStatus.saved,
            component: edited,
            savedComponent: edited,
          ),
        ],
        verify: (_) => verify(
          () => componentRepository.writeComponentCode(
            project.path,
            'lib/game',
            edited,
          ),
        ).called(1),
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'does nothing while saving',
        build: buildBloc,
        seed: () => const ComponentEditorState(
          status: ComponentEditorStatus.saving,
          component: edited,
          savedComponent: component,
        ),
        act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
        expect: () => const <ComponentEditorState>[],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'does nothing without changes',
        build: buildBloc,
        act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
        expect: () => const <ComponentEditorState>[],
        verify: (_) =>
            verifyNever(() => componentRepository.saveComponent(any(), any())),
      );
    });

    group(ComponentEditorNameChanged, () {
      const named = RectangleComponent(
        name: 'Player',
        children: [
          RectangleComponent(name: 'rectangle1'),
          RectangleComponent(name: 'rectangle2'),
        ],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'renames the selected child',
        build: buildBloc,
        seed: () => const ComponentEditorState(
          component: named,
          savedComponent: named,
          selectedPath: [1],
        ),
        act: (bloc) => bloc.add(const ComponentEditorNameChanged('head')),
        expect: () => [
          isA<ComponentEditorState>().having(
            (s) => s.component.nodeAt(const [1]).name,
            'name',
            'head',
          ),
        ],
      );

      for (final name in ['rectangle1', 'size', '1head']) {
        blocTest<ComponentEditorBloc, ComponentEditorState>(
          'ignores the rejected name "$name"',
          build: buildBloc,
          seed: () => const ComponentEditorState(
            component: named,
            savedComponent: named,
            selectedPath: [1],
          ),
          act: (bloc) => bloc.add(ComponentEditorNameChanged(name)),
          expect: () => const <ComponentEditorState>[],
        );
      }

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'ignores a name whose class another component generates',
        build: buildBloc,
        seed: () => const ComponentEditorState(
          component: named,
          savedComponent: named,
          selectedPath: [1],
          takenClassNames: {
            r'$PlayerHead': RectangleComponent(name: 'player_head'),
          },
        ),
        act: (bloc) => bloc.add(const ComponentEditorNameChanged('head')),
        expect: () => const <ComponentEditorState>[],
      );

      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'does not rename the root',
        build: buildBloc,
        seed: () =>
            const ComponentEditorState(component: named, savedComponent: named),
        act: (bloc) => bloc.add(const ComponentEditorNameChanged('Enemy')),
        expect: () => const <ComponentEditorState>[],
      );
    });
  });
}
