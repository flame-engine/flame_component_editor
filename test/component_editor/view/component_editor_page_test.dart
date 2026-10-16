import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/component_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_repository/project_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  const project = Project(path: '/projects/my_game');
  const component = Component(name: 'Player');

  group(ComponentEditorPage, () {
    testWidgets('route shows the component name', (tester) async {
      await tester.pumpApp(
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
      await tester.pumpAndSettle();

      expect(find.text('Player'), findsOneWidget);
      expect(find.text('Component editor coming soon'), findsOneWidget);
    });
  });
}
