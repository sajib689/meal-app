class BazarModel {
  final String id;
  final String userId;
  final String userName;
  final List<String> items;
  final double totalCost;
  final String date;
  final String month;
  final bool isApproved;
  final String? description;
  final String? messId;

  BazarModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalCost,
    required this.date,
    required this.month,
    required this.isApproved,
    this.description,
    this.messId,
  });

  factory BazarModel.fromJson(Map<String, dynamic> json) {
    String extractUserId(dynamic user) {
      if (user == null) return '';
      if (user is String) return user;
      if (user is Map) return user['_id'] ?? user['id'] ?? '';
      return '';
    }

    String extractUserName(dynamic user) {
      if (user == null) return 'Unknown';
      if (user is String) return 'Member';
      if (user is Map) return user['name'] ?? 'Member';
      return 'Member';
    }

    return BazarModel(
      id: json['_id'] ?? '',
      userId: extractUserId(json['userId']),
      userName: extractUserName(json['userId']),
      items: List<String>.from(json['items'] ?? []),
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      month: json['month'] ?? '',
      isApproved: json['isApproved'] ?? false,
      description: json['description'],
      messId: json['messId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'items': items,
      'totalCost': totalCost,
      'date': date,
      'month': month,
      'isApproved': isApproved,
      'description': description,
      'messId': messId,
    };
  }
}
