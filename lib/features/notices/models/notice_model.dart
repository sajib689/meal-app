class NoticeModel {
  final String id;
  final String title;
  final String content;
  final String createdBy;
  final String creatorName;
  final bool isActive;
  final DateTime createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.creatorName,
    required this.isActive,
    required this.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    String extractCreatedBy(dynamic user) {
      if (user == null) return '';
      if (user is String) return user;
      if (user is Map) return user['_id'] ?? user['id'] ?? '';
      return '';
    }

    String extractCreatorName(dynamic user) {
      if (user == null) return 'Admin';
      if (user is String) return 'Admin';
      if (user is Map) return user['name'] ?? 'Admin';
      return 'Admin';
    }

    return NoticeModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdBy: extractCreatedBy(json['createdBy']),
      creatorName: extractCreatorName(json['createdBy']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
