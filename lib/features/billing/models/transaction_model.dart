class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'deposit' or 'deduction'
  final String? description;
  final DateTime date;
  final String? messId;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.messId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String extractUserId(dynamic user) {
      if (user == null) return '';
      if (user is String) return user;
      if (user is Map) return user['_id'] ?? user['id'] ?? '';
      return '';
    }

    return TransactionModel(
      id: json['_id'] ?? '',
      userId: extractUserId(json['userId']),
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'deposit',
      description: json['description'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      messId: json['messId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'messId': messId,
    };
  }
}
