import 'dart:convert';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/domain/entities/transaction_history.dart';

import 'package:http/http.dart' as http;

import '../../../domain/repositories/transaction_history_repository.dart';
import '../../models/transaction_history_dto.dart';
import 'mock.dart';

class TransactionHistoryImpl extends TransactionHistoryRepository {
  final http.Client client;

  TransactionHistoryImpl({required this.client});

  @override
  Future<Result<List<TransactionHistory>>> getTransactionHistory(String walletId) async {
    await Future.delayed(Duration(seconds: 2));
    var res = json.decode(txHistoryResponse);
    var txHistoryData = res['transactions'] as List<dynamic>;
    return Result.success(
      txHistoryData
          .map((transaction) => TransactionHistoryDto.fromJson(transaction).toDomain())
          .toList(),
    );
  }
}
