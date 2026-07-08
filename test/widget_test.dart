import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/main.dart';
import 'package:gym_app/providers/auth_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final authProvider = AuthProvider();
    await tester.pumpWidget(MyApp(authProvider: authProvider));
    await tester.pump();
    expect(find.text('GYM MANAGEMENT'), findsOneWidget);
  });
}
