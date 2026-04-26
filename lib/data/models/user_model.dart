class UserModel {
  final int id;
  final String name;
  final String avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '👨',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
