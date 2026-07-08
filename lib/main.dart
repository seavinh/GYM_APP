import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/member_provider.dart';
import 'providers/trainer_provider.dart';
import 'providers/membership_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/equipment_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/receptionist/receptionist_shell.dart';
import 'screens/member/member_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ChangeNotifierProvider(create: (_) => MembershipProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => EquipmentProvider()),
      ],
      child: MaterialApp(
        title: 'GYM Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        switch (auth.user?.role) {
          case 'admin':
            return const AdminShell();
          case 'receptionist':
            return const ReceptionistShell();
          case 'member':
            return const MemberShell();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
