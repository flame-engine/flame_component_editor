import 'package:bloc_test/bloc_test.dart';
import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/component_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_repository/project_repository.dart';

class _MockComponentRepository extends Mock implements ComponentRepository;

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

    setUp(() {
      componentRepository = _MockComponentRepository();
    });

    ComponentEditorBloc buildBloc() => ComponentEditorBloc(
      project: project,
      component: component,
      componentRepository: componentRepository,
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
      blocTest<ComponentEditorBloc, ComponentEditorState>(
        'saves the component and clears the changes',
        setUp: () =>
            when(() => componentRepository.saveComponent(project.path, edited))
                .thenAnswer((_) async {}),
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
        verify: (_) => verify(
          () => componentRepository.saveComponent(project.path, edited),
        ).called(1),
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
        'does nothing without changes',
        build: buildBloc,
        act: (bloc) => bloc.add(const ComponentEditorSaveRequested()),
        expect: () => const <ComponentEditorState>[],
        verify: (_) =>
            verifyNever(() => componentRepository.saveComponent(any(), any())),
      );
    });
  });
}
