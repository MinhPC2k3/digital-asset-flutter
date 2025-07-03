import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Result<Transaction>> buildRawTransaction(Transaction transaction);

  Future<Result<List<String>>> prepareSign(SignInfo signInfo, Transaction transaction);

  Future<Result<SignInfo>> invokeSign(SignInfo signInfo, Transaction transaction);

  Future<Result<Signature>> combineSignature(SignInfo signInfo, Transaction transaction);

  Future<Result<String>> sendNative(SignInfo signInfo, Transaction transaction);

  Future<Result<List<TransactionHistoryData>>> getHistory(String walletAddress);

  Future<Result<TransactionSwap>> getQuote (TransactionSwap txSwap);
}
