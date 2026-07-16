import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'controllers/auth_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/member_controller.dart';
import 'controllers/trainer_controller.dart';
import 'controllers/membership_controller.dart';
import 'controllers/attendance_controller.dart';
import 'controllers/payment_controller.dart';
import 'controllers/equipment_controller.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/receptionist/receptionist_shell.dart';
import 'screens/member/member_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authController = Get.put(AuthController());
  await authController.init();

  // Initialize other controllers globally
  Get.put(DashboardController());
  Get.put(MemberController());
  Get.put(TrainerController());
  Get.put(MembershipController());
  Get.put(AttendanceController());
  Get.put(PaymentController());
  Get.put(EquipmentController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GYM Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (auth) {
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        switch (auth.user?.role) {
          case AppConstants.roleAdmin:
            return const AdminShell();
          case AppConstants.roleReceptionist:
            return const ReceptionistShell();
          case AppConstants.roleMember:
            return const MemberShell();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
