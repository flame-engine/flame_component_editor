import 'package:flame_component_editor/app/app.dart';
import 'package:flame_component_editor/home/home.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_repository/project_repository.dart';

class _MockProjectRepository extends Mock implements ProjectRepository;

void main() {
  group(App, () {
    testWidgets('renders the home view', (tester) async {
      final projectRepository = _MockProjectRepository();
      when(projectRepository.getRecentProjects).thenAnswer((_) async => []);

      await tester.pumpWidget(App(projectRepository: projectRepository));

      expect(find.byType(HomeView), findsOneWidget);
    });
  });
}
