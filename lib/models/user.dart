class User {
  final String accessToken;
  final String id;
  final String email;
  final DateTime? createAt;

  const User({
    required this.accessToken,
    required this.id,
    required this.email,
    required this.createAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return User(
      accessToken: json['access_token'] ?? '',
      id: user['id'] ?? '',
      email: user['email'] ?? '',
      createAt: user['create_at'],
    );
  }

  static const empty = User(id: '', email: '', accessToken: '', createAt: null);

}
