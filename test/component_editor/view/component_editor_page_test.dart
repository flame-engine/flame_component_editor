import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:component_repository/component_repository.dart';
import 'package:flame/game.dart';
import 'package:flame_component_editor/component_editor/component_editor.dart';
import 'package:flame_component_editor/component_editor/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_repository/project_repository.dart';

import '../../helpers/helpers.dart';

class _MockComponentRepository extends Mock implements ComponentRepository;

class _MockComponentEditorBloc
    extends MockBloc<ComponentEditorEvent, ComponentEditorState>
    implements ComponentEditorBloc;

void main() {
  const project = Project(path: '/projects/my_game');
  const component = RectangleComponent(name: 'Player');
  const edited = RectangleComponent(
    name: 'Player',
    size: ComponentSize(width: 10),
  );

  setUpAll(() => registerFallbackValue(const ComponentEditorSaveRequested()));

  group(ComponentEditorPage, () {
    testWidgets('route shows the editor for the component', (tester) async {
      final componentRepository = _MockComponentRepository();
      when(() => componentRepository.getComponents(project.path))
          .thenAnswer((_) async => const [component]);
      await tester.pumpApp(
        componentRepository: componentRepository,
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .push(ComponentEditorPage.route(project, component)),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Player'), findsOneWidget);
      verify(() => componentRepository.getComponents(project.path)).called(1);
    });
  });

  group(ComponentEditorView, () {
    late ComponentEditorBloc bloc;

    setUp(() {
      bloc = _MockComponentEditorBloc();
      when(() => bloc.state).thenReturn(
        const ComponentEditorState(
          component: component,
          savedComponent: component,
        ),
      );
    });

    Widget buildSubject() =>
        BlocProvider.value(value: bloc, child: const ComponentEditorView());

    testWidgets('shows the preview and the property editors', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(ComponentPreview), findsOneWidget);
      expect(find.byType(GameWidget<ComponentPreviewGame>), findsOneWidget);
      expect(find.byType(SizeEditor), findsOneWidget);
      expect(find.byType(PaintEditor), findsOneWidget);
    });

    testWidgets('dispatches size changes', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.enterText(find.widgetWithText(TextField, 'Width'), '10');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      verify(
        () => bloc.add(
          const ComponentEditorSizeChanged(ComponentSize(width: 10)),
        ),
      ).called(1);
    });

    testWidgets('dispatches paint changes', (tester) async {
      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Stroke'));

      verify(
        () => bloc.add(
          const ComponentEditorPaintChanged(
            ComponentPaint(style: PaintStyle.stroke),
          ),
        ),
      ).called(1);
    });

    group('component tree', () {
      const child = RectangleComponent(
        name: 'rectangle1',
        position: ComponentPosition(x: 5, y: 6),
      );
      const tree = RectangleComponent(name: 'Player', children: [child]);

      void stubTree({List<int> selectedPath = const []}) {
        when(() => bloc.state).thenReturn(
          ComponentEditorState(
            component: tree,
            savedComponent: tree,
            selectedPath: selectedPath,
            takenClassNames: const {r'$PlayerEye'},
          ),
        );
      }

      testWidgets('lists the root and its children', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        final panel = find.byType(ComponentTreePanel);
        expect(panel, findsOneWidget);
        expect(
          find.descendant(of: panel, matching: find.text('Player')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: panel, matching: find.text('rectangle1')),
          findsOneWidget,
        );
        final root = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Player'),
        );
        expect(root.selected, isTrue);
      });

      testWidgets('selects a node when tapped', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        await tester.tap(find.text('rectangle1'));

        verify(() => bloc.add(const ComponentEditorNodeSelected([0])))
            .called(1);
      });

      testWidgets('adds a child of the picked type', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Add child'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Rectangle'));

        verify(
          () => bloc.add(
            const ComponentEditorChildAdded(ComponentType.rectangle),
          ),
        ).called(1);
      });

      testWidgets('cannot remove the root', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        final remove = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.delete_outline),
        );
        expect(remove.onPressed, isNull);
      });

      testWidgets('removes the selected child', (tester) async {
        stubTree(selectedPath: [0]);
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Remove'));

        verify(() => bloc.add(const ComponentEditorNodeRemoved([0]))).called(1);
      });

      testWidgets('hides the position of the root', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        expect(find.byType(PositionEditor), findsNothing);
        expect(find.byType(SizeEditor), findsOneWidget);
      });

      testWidgets('hides the name of the root', (tester) async {
        stubTree();
        await tester.pumpApp(buildSubject());

        expect(find.byType(NameField), findsNothing);
      });

      testWidgets('renames a selected child', (tester) async {
        stubTree(selectedPath: [0]);
        await tester.pumpApp(buildSubject());

        final field = find.byType(NameField);
        expect(
          find.descendant(of: field, matching: find.text('rectangle1')),
          findsOneWidget,
        );

        await tester.enterText(field, 'head');

        verify(() => bloc.add(const ComponentEditorNameChanged('head')))
            .called(1);
      });

      for (final (name, message) in [
        ('1head', 'Use a valid Dart identifier'),
        ('size', 'Already a member of the parent component in Flame'),
        ('Player', 'Another component already uses this name'),
        ('eye', 'Generates the same class as a part of another component'),
      ]) {
        testWidgets('rejects the child name "$name"', (tester) async {
          stubTree(selectedPath: [0]);
          await tester.pumpApp(buildSubject());

          await tester.enterText(find.byType(NameField), name);
          await tester.pump();

          expect(find.textContaining(message), findsOneWidget);
          verifyNever(() => bloc.add(ComponentEditorNameChanged(name)));
        });
      }

      testWidgets('edits the position of a selected child', (tester) async {
        stubTree(selectedPath: [0]);
        await tester.pumpApp(buildSubject());

        expect(find.byType(PositionEditor), findsOneWidget);
        expect(find.widgetWithText(TextField, '5'), findsOneWidget);

        await tester.enterText(find.widgetWithText(TextField, 'X'), '-10');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        verify(
          () => bloc.add(
            const ComponentEditorPositionChanged(
              ComponentPosition(x: -10, y: 6),
            ),
          ),
        ).called(1);
      });
    });

    testWidgets('disables save without changes', (tester) async {
      await tester.pumpApp(buildSubject());

      final save = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.save_outlined),
      );
      expect(save.onPressed, isNull);
      expect(find.widgetWithText(AppBar, 'Player'), findsOneWidget);
    });

    testWidgets('saves without changes when the code is outdated', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const ComponentEditorState(
          status: ComponentEditorStatus.classConflict,
          component: component,
          savedComponent: component,
          isCodeOutdated: true,
        ),
      );
      await tester.pumpApp(buildSubject());

      expect(find.text('Player •'), findsNothing);
      await tester.tap(find.byTooltip('Save'));

      verify(() => bloc.add(const ComponentEditorSaveRequested())).called(1);
    });

    group('with changes', () {
      setUp(() {
        when(() => bloc.state).thenReturn(
          const ComponentEditorState(
            component: edited,
            savedComponent: component,
          ),
        );
      });

      testWidgets('marks the title', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.text('Player •'), findsOneWidget);
      });

      testWidgets('saves with the save button', (tester) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byTooltip('Save'));

        verify(() => bloc.add(const ComponentEditorSaveRequested())).called(1);
      });

      testWidgets('saves with the keyboard shortcut', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);

        verify(() => bloc.add(const ComponentEditorSaveRequested())).called(1);
      });
    });

    testWidgets('shows a message when saving fails', (tester) async {
      whenListen(
        bloc,
        Stream.value(
          const ComponentEditorState(
            status: ComponentEditorStatus.failure,
            component: edited,
            savedComponent: component,
          ),
        ),
        initialState: const ComponentEditorState(
          component: edited,
          savedComponent: component,
        ),
      );

      await tester.pumpApp(buildSubject());
      await tester.pump();

      expect(find.text('Could not save the component'), findsOneWidget);
    });

    testWidgets('shows the clashing classes for classConflict', (tester) async {
      const tree = RectangleComponent(
        name: 'Player',
        children: [RectangleComponent(name: 'head')],
      );
      whenListen(
        bloc,
        Stream.value(
          const ComponentEditorState(
            status: ComponentEditorStatus.classConflict,
            component: tree,
            savedComponent: tree,
            takenClassNames: {r'$PlayerHead', r'$Enemy'},
          ),
        ),
        initialState: const ComponentEditorState(
          component: tree,
          savedComponent: component,
        ),
      );

      await tester.pumpApp(buildSubject());
      await tester.pump();

      expect(
        find.textContaining(r'other components also generate $PlayerHead.'),
        findsOneWidget,
      );
    });

    for (final (status, message) in [
      (ComponentEditorStatus.codeConflict, 'a file that was not generated'),
      (ComponentEditorStatus.codeFailure, 'the code could not be generated'),
    ]) {
      testWidgets('shows a message for $status', (tester) async {
        whenListen(
          bloc,
          Stream.value(
            ComponentEditorState(
              status: status,
              component: edited,
              savedComponent: edited,
            ),
          ),
          initialState: const ComponentEditorState(
            component: edited,
            savedComponent: component,
          ),
        );

        await tester.pumpApp(buildSubject());
        await tester.pump();

        expect(find.textContaining(message), findsOneWidget);
      });
    }
  });

  group('leaving the editor', () {
    const unsaved = ComponentEditorState(
      component: edited,
      savedComponent: component,
    );

    late ComponentEditorBloc bloc;
    late StreamController<ComponentEditorState> states;

    setUp(() {
      bloc = _MockComponentEditorBloc();
      states = StreamController.broadcast();
      whenListen(bloc, states.stream, initialState: unsaved);
    });

    tearDown(() => states.close());

    Future<void> openEditor(WidgetTester tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: const ComponentEditorView(),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpRouteTransition();
    }

    Future<void> leave(WidgetTester tester) async {
      await tester.pageBack();
      await tester.pumpRouteTransition();
    }

    testWidgets('leaves directly without changes', (tester) async {
      whenListen(
        bloc,
        const Stream<ComponentEditorState>.empty(),
        initialState: const ComponentEditorState(
          component: component,
          savedComponent: component,
        ),
      );
      await openEditor(tester);

      await leave(tester);

      expect(find.byType(UnsavedChangesDialog), findsNothing);
      expect(find.byType(ComponentEditorView), findsNothing);
    });

    testWidgets('asks before leaving with changes', (tester) async {
      await openEditor(tester);

      await leave(tester);

      expect(find.byType(UnsavedChangesDialog), findsOneWidget);
    });

    testWidgets('stays when cancelled', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpRouteTransition();

      expect(find.byType(UnsavedChangesDialog), findsNothing);
      expect(find.byType(ComponentEditorView), findsOneWidget);
    });

    testWidgets('leaves without saving when discarded', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Discard'));
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsNothing);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('saves and leaves when saving succeeds', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      verify(() => bloc.add(const ComponentEditorSaveRequested())).called(1);

      states.add(
        const ComponentEditorState(
          status: ComponentEditorStatus.saved,
          component: edited,
          savedComponent: edited,
        ),
      );
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsNothing);
    });

    testWidgets('leaves when saved without generating the code', (
      tester,
    ) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      states.add(
        const ComponentEditorState(
          status: ComponentEditorStatus.codeFailure,
          component: edited,
          savedComponent: edited,
        ),
      );
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsNothing);
    });

    testWidgets('stays when saving fails', (tester) async {
      await openEditor(tester);
      await leave(tester);

      await tester.tap(find.text('Save'));
      await tester.pump();
      states.add(unsaved.copyWith(status: ComponentEditorStatus.failure));
      await tester.pumpRouteTransition();

      expect(find.byType(ComponentEditorView), findsOneWidget);
      expect(find.text('Could not save the component'), findsOneWidget);
    });
  });
}
