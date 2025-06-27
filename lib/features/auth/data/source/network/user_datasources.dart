import 'dart:convert';

import 'package:digital_asset_flutter/core/constants/api_constans.dart';
import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/auth/domain/entities/user.dart';
import 'package:digital_asset_flutter/features/auth/domain/repositories/user_repository.dart';
import 'package:http/http.dart' as http;
import '../../DTO/user_dto.dart' as user_model;

class UserRepositoryImpl implements UserRepository {
  final http.Client client;

  UserRepositoryImpl(this.client);

  @override
  Future<Result<User>> userLogin(String token) async {
    String url = ApiEndpoints.login;
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, String> body = {'id_token': token};
    print("Doing login $token");
    String reqBody = jsonEncode(body);
    http.Response res = await client.post(Uri.parse(url), headers: headers, body: reqBody);
    user_model.UserDTO userDTO = user_model.UserDTO.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
    print("Request $body");
    print("Response ${res.body}");
    if (res.statusCode == 200) {
      return Result.success(userDTO.toDomain());
    } else {
      final json = jsonDecode(res.body);
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<User>> userRegister(String token) async {
    String url = ApiEndpoints.register;
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, String> body = {'id_token': token};
    String reqBody = jsonEncode(body);

    http.Response res = await http.post(Uri.parse(url), headers: headers, body: reqBody);
    user_model.UserDTO userDTO = user_model.UserDTO.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
    if (res.statusCode == 200) {
      return Result.success(userDTO.toDomain());
    } else {
      final json = jsonDecode(res.body);
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }
}
