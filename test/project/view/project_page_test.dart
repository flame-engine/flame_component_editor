import 'package:flame_component_editor/project/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_repository/project_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  const project = Project(path: '/projects/my_game');

  group(ProjectPage, () {
    testWidgets('shows the project name and path', (tester) async {
      await tester.pumpApp(const ProjectPage(project: project));

      expect(find.text('my_game'), findsOneWidget);
      expect(find.text('/projects/my_game'), findsOneWidget);
    });

    testWidgets('route can be pushed and popped', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                Navigator.of(context).push(ProjectPage.route(project)),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectPage), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ProjectPage), findsNothing);
    });
  });
}
