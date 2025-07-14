import 'dart:convert';

import 'package:digital_asset_flutter/core/constants/api_constans.dart';
import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:http/http.dart' as http;

import '../../../domain/repositories/homepage_repository.dart';
import '../../models/wallet_dto.dart';

class HomepageRepositoriesImpl implements HomepageRepository {
  final http.Client client;

  HomepageRepositoriesImpl({required this.client});

  @override
  Future<Result<List<Wallet>>> getWallets(String userId) async {
    Map<String, String> queryParams = {'userId': userId};

    Map<String, String> headers = {"Content-type": "application/json"};

    var uri = Uri.parse(ApiEndpointsV2.getUserWalletUrl);
    final requestUri = uri.replace(queryParameters: queryParams);
    http.Response res = await client.get(
      // Uri.http(uri.host, uri.path, queryParams),
      requestUri,
      headers: headers,
    );
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);
      final List<dynamic> dataList = decoded['wallets'];
      final userWallet = dataList.map((item) => WalletDTO.fromJson(item).toEntity()).toList();

      return Result.success(userWallet);
    } else {
      final json = jsonDecode(res.body);
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? "Unexpected error"),
      );
    }
  }
}
