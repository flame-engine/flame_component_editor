import 'package:flame_component_editor/project_settings/project_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_repository/project_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  const project = Project(path: '/projects/my_game');

  group(ProjectSettingsPage, () {
    testWidgets('route shows the settings placeholder', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                Navigator.of(context).push(ProjectSettingsPage.route(project)),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('my_game settings'), findsOneWidget);
      expect(find.text('Settings coming soon'), findsOneWidget);
    });
  });
}
