import '../../domain/entities/user.dart';

class UserDTO {
  final String accessToken;
  final String id;
  final String email;
  final DateTime? createAt;

  const UserDTO({
    required this.accessToken,
    required this.id,
    required this.email,
    required this.createAt,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return UserDTO(
      accessToken: json['access_token'] ?? '',
      id: user['id'] ?? '',
      email: user['email'] ?? '',
      createAt: user['create_at'],
    );
  }

  User toDomain() {
    return User(
      accessToken: accessToken,
      id: id,
      email: email,
      createAt: createAt,
    );
  }

  factory UserDTO.formDomain(User user) {
    return UserDTO(
      accessToken: user.accessToken,
      email: user.email,
      id: user.id,
      createAt: user.createAt,
    );
  }
}
