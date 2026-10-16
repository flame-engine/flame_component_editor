import 'package:flame_component_editor/component_editor/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(NumberField, () {
    late List<double> changes;

    setUp(() => changes = []);

    Widget buildSubject(double value) => MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            NumberField(label: 'Width', value: value, onChanged: changes.add),
            const TextField(key: Key('other')),
          ],
        ),
      ),
    );

    testWidgets('shows whole numbers without decimals', (tester) async {
      await tester.pumpWidget(buildSubject(50));
      expect(find.text('50'), findsOneWidget);

      await tester.pumpWidget(buildSubject(12.5));
      expect(find.text('12.5'), findsOneWidget);
    });

    testWidgets('commits on submit', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      await tester.enterText(find.byType(NumberField), '12.5');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([12.5]));
    });

    testWidgets('commits when losing focus', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      await tester.enterText(find.byType(NumberField), '10');
      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();

      expect(changes, equals([10]));
    });

    testWidgets('reverts invalid input', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      for (final input in ['abc', '-1']) {
        await tester.enterText(find.byType(NumberField), input);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(find.text('50'), findsOneWidget);
      }
      expect(changes, isEmpty);
    });

    testWidgets('does not commit an unchanged value', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      await tester.enterText(find.byType(NumberField), '50.0');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, isEmpty);
    });
  });
}
