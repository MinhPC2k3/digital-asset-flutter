import 'dart:convert';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/domain/entities/transaction_history.dart';

import 'package:http/http.dart' as http;

import '../../../../../core/constants/api_constans.dart';
import '../../../domain/repositories/transaction_history_repository.dart';
import '../../models/transaction_history_dto.dart';
import 'mock.dart';

class TransactionHistoryImpl extends TransactionHistoryRepository {
  final http.Client client;

  TransactionHistoryImpl({required this.client});

  @override
  Future<Result<List<TransactionHistory>>> getTransactionHistory(String walletAddress) async {
    Map<String, String> queryParams = {'address': walletAddress};

    Map<String, String> headers = {"Content-type": "application/json"};

    var uri = Uri.parse(ApiEndpointsV2.getTransactionHistory);
    final requestUri = uri.replace(queryParameters: queryParams);
    http.Response res = await client.get(
      // Uri.http(uri.host, uri.path, queryParams),
      requestUri,
      headers: headers,
    );
    if (res.statusCode == 200) {
      print("Get user wallet success");
      final Map<String, dynamic> decoded = json.decode(res.body);
      print("Response ${decoded}");
      final List<dynamic> dataList = decoded['transactions'];
      final transactionHistory =
          dataList.map((item) => TransactionHistoryDto.fromJson(item).toDomain()).toList();

      return Result.success(transactionHistory);
    } else {
      final json = jsonDecode(res.body);
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? "Unexpected error"),
      );
    }
  }
}
