import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard(context.read<AuthProvider>());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          if (dashboard.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
          }

          if (dashboard.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Something went wrong',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dashboard.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => dashboard.loadDashboard(context.read<AuthProvider>()),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = dashboard.data;
          if (data == null) return const SizedBox();

          return RefreshIndicator(
            onRefresh: () => dashboard.loadDashboard(context.read<AuthProvider>()),
            color: AppTheme.accentTeal,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.3,
                  children: [
                    _StatCard(
                      icon: Icons.people_rounded,
                      label: 'Total Members',
                      value: '${data.totalMembers}',
                      color: AppTheme.accentTeal,
                      gradient: [AppTheme.accentTeal.withAlpha(20), AppTheme.accentTeal.withAlpha(5)],
                    ),
                    _StatCard(
                      icon: Icons.verified_user_rounded,
                      label: 'Active',
                      value: '${data.activeMembers}',
                      color: AppTheme.success,
                      gradient: [AppTheme.success.withAlpha(20), AppTheme.success.withAlpha(5)],
                    ),
                    _StatCard(
                      icon: Icons.attach_money_rounded,
                      label: 'Revenue',
                      value: '\$${data.monthlyRevenue.toStringAsFixed(0)}',
                      color: AppTheme.accentYellow,
                      gradient: [AppTheme.accentYellow.withAlpha(20), AppTheme.accentYellow.withAlpha(5)],
                    ),
                    _StatCard(
                      icon: Icons.login_rounded,
                      label: 'Check-ins',
                      value: '${data.dailyCheckIns}',
                      color: AppTheme.accentPurple,
                      gradient: [AppTheme.accentPurple.withAlpha(20), AppTheme.accentPurple.withAlpha(5)],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.glassCard,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.circle, color: AppTheme.success, size: 12),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Currently Active', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(
                              'Members checked in right now',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${data.activeNow}',
                        style: const TextStyle(
                          color: AppTheme.accentTeal,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final List<Color> gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(30), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
