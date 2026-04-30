class ReportModel {
  final String id;
  final String month;
  final double totalMeals;
  final double totalBazarCost;
  final double mealRate;
  final List<MemberStat> memberStats;
  final bool isFinalized;

  ReportModel({
    required this.id,
    required this.month,
    required this.totalMeals,
    required this.totalBazarCost,
    required this.mealRate,
    required this.memberStats,
    required this.isFinalized,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] ?? '',
      month: json['month'] ?? '',
      totalMeals: (json['totalMeals'] ?? 0).toDouble(),
      totalBazarCost: (json['totalBazarCost'] ?? 0).toDouble(),
      mealRate: (json['mealRate'] ?? 0).toDouble(),
      memberStats: (json['memberStats'] as List? ?? [])
          .map((i) => MemberStat.fromJson(i))
          .toList(),
      isFinalized: json['isFinalized'] ?? false,
    );
  }
}

class MemberStat {
  final String userId;
  final double totalMeals;
  final double totalCost;
  final double bazarTotal;
  final double balance;

  MemberStat({
    required this.userId,
    required this.totalMeals,
    required this.totalCost,
    required this.bazarTotal,
    required this.balance,
  });

  factory MemberStat.fromJson(Map<String, dynamic> json) {
    return MemberStat(
      userId: json['userId'] ?? '',
      totalMeals: (json['totalMeals'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      bazarTotal: (json['bazarTotal'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}
