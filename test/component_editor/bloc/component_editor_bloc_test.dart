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
