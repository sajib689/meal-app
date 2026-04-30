class MealModel {
  final String id;
  final String userId;
  final String date;
  final double breakfast;
  final double lunch;
  final double dinner;
  final bool isLocked;
  final String? messId;

  MealModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.isLocked,
    this.messId,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    String extractUserId(dynamic user) {
      if (user == null) return '';
      if (user is String) return user;
      if (user is Map) return user['_id'] ?? user['id'] ?? '';
      return '';
    }

    return MealModel(
      id: json['_id'] ?? '',
      userId: extractUserId(json['userId']),
      date: json['date'] ?? '',
      breakfast: (json['breakfast'] ?? 0).toDouble(),
      lunch: (json['lunch'] ?? 0).toDouble(),
      dinner: (json['dinner'] ?? 0).toDouble(),
      isLocked: json['isLocked'] ?? false,
      messId: json['messId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'date': date,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'isLocked': isLocked,
      'messId': messId,
    };
  }
}
