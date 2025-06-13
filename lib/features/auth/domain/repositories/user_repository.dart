import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<Result<User>> userLogin(String token);

  Future<Result<User>> userRegister(String token);
}
