import 'package:flame_component_editor/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(App, () {
    testWidgets('renders the editor title', (tester) async {
      await tester.pumpWidget(const App());

      expect(find.text('Flame Component Editor'), findsOneWidget);
    });
  });
}
