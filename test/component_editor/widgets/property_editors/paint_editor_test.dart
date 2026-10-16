import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/widgets.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(PaintEditor, () {
    late List<ComponentPaint> changes;

    setUp(() => changes = []);

    Future<void> pumpSubject(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaintEditor(
            value: const ComponentPaint(color: 0xFF112233),
            onChanged: changes.add,
          ),
        ),
      ),
    );

    testWidgets('shows the color hex code', (tester) async {
      await pumpSubject(tester);

      expect(find.text('#FF112233'), findsOneWidget);
    });

    testWidgets('edits the style', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.text('Stroke'));

      expect(
        changes,
        equals([
          const ComponentPaint(color: 0xFF112233, style: PaintStyle.stroke),
        ]),
      );
    });

    testWidgets('opens a color picker for the color', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.byType(ColorField));
      await tester.pumpAndSettle();

      expect(find.byType(ColorPicker), findsOneWidget);
    });

    testWidgets('keeps the color when the picker is cancelled', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.byType(ColorField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
    });
  });
}
