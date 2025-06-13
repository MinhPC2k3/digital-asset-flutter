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
}
