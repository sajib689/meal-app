class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final bool isMealStopped;
  final double balance;
  final String? messId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    required this.isMealStopped,
    required this.balance,
    this.messId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'active',
      isMealStopped: json['isMealStopped'] ?? false,
      balance: (json['balance'] ?? 0).toDouble(),
      messId: json['messId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'isMealStopped': isMealStopped,
      'balance': balance,
      'messId': messId,
    };
  }
}
