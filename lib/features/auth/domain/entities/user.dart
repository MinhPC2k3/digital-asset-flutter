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

  factory User.empty() {
    return User(accessToken: '', id: '', email: '', createAt: null);
  }

  User clearData() {
    return User.empty();
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(accessToken: '', id: json['id'], email: json['email'], createAt: null);
  }
}
