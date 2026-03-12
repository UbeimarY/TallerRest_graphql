import 'package:flutter_test/flutter_test.dart';
import 'package:rest_graphql/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldExplorerApp());
    expect(find.byType(WorldExplorerApp), findsOneWidget);
  });
}
