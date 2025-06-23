import 'package:flutter/foundation.dart';

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

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}