import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/entities/quote.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';

abstract class TransactionSwapRepository {
  Future<Result<TransactionQuote>> getQuote(TransactionQuote txQuote);

  Future<Result<List<Asset>>> getListAsset();

  Future<Result<Transaction>> buildRawTransaction(Transaction transaction);

  Future<Result<List<String>>> prepareSign(SignInfo signInfo, Transaction transaction);

  Future<Result<SignInfo>> invokeSign(SignInfo signInfo, Transaction transaction);

  Future<Result<Signature>> combineSignature(SignInfo signInfo, Transaction transaction);

  Future<Result<String>> sendNative(SignInfo signInfo, Transaction transaction);
}
