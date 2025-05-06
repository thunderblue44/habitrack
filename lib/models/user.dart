class User {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin:
          json['last_login'] != null
              ? DateTime.parse(json['last_login'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }
}
