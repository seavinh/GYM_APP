class DashboardData {
  final int totalMembers;
  final int activeMembers;
  final double monthlyRevenue;
  final int dailyCheckIns;
  final int activeNow;

  DashboardData({
    required this.totalMembers,
    required this.activeMembers,
    required this.monthlyRevenue,
    required this.dailyCheckIns,
    required this.activeNow,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalMembers: json['total_members'] ?? 0,
      activeMembers: json['active_members'] ?? 0,
      monthlyRevenue: double.parse((json['monthly_revenue'] ?? 0).toString()),
      dailyCheckIns: json['daily_check_ins'] ?? 0,
      activeNow: json['active_now'] ?? 0,
    );
  }
}
