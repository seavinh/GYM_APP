import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gym_app/main.dart';
import 'package:gym_app/controllers/auth_controller.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    Get.put(AuthController());
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.text('GYM MANAGEMENT'), findsOneWidget);
  });
}
