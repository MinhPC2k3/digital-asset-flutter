import 'dart:convert';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart' as transaction_model;
import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/entities/quote.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/repositories/transaction_swap_repository.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/helper/dart_ffi.dart';
import '../../../../core/helper/helper.dart';

class TransactionSwapUsecase {
  final TransactionSwapRepository _transactionSwapRepository;

  TransactionSwapUsecase({required TransactionSwapRepository repository})
    : _transactionSwapRepository = repository;

  Future<Result<TransactionQuote>> getQuote(
    Asset fromAsset,
    toAsset,
    Wallet fromWallet,
    Wallet toWallet,
    double amount,
  ) {
    var swapTransaction = TransactionQuote(
      id: '',
      fromAsset: fromAsset,
      toAsset: toAsset,
      fromWallet: fromWallet,
      toWallet: toWallet,
      amountSwap: amount,
      amountReceive: 0,
      estimatedFee: 0,
      rate: 0,
      status: '',
      expirationAt: DateTime.timestamp(),
      depositAddress: '',
    );
    return _transactionSwapRepository.getQuote(swapTransaction);
  }

  Future<Result<List<Asset>>> getListAsset() async {
    var res = await _transactionSwapRepository.getListAsset();
    if (!res.isSuccess) {
      print("Request list asset fail ${res.error!.message}");
    }
    return res;
  }

  Future<Result<transaction_model.SignInfo>> prepareSign(
      transaction_model.Transaction transaction,
      ) async {
    Result<transaction_model.Transaction> rawTransaction = await _transactionSwapRepository
        .buildRawTransaction(transaction);
    if (!rawTransaction.isSuccess) {
      return Result<transaction_model.SignInfo>.failure(rawTransaction.error);
    }
    print("Transaction object after ${transaction.toString()}");
    print("RawTx before finger print ${rawTransaction.data!.rawEthereumTransaction.ethereumTx}");
    var fingerprint = await GoBridge.getFingerprint(
      '1234',
      rawTransaction.data!.rawEthereumTransaction.ethereumTx['nonce'],
      rawTransaction.data!.rawEthereumTransaction.ethereumTx['to'],
      rawTransaction.data!.rawEthereumTransaction.ethereumTx['value'],
      rawTransaction.data!.rawEthereumTransaction.ethereumTx['gas'],
      rawTransaction.data!.rawEthereumTransaction.ethereumTx['gasPrice'],
      rawTransaction.data!.rawEthereumTransaction.ethereumTx['input'],
    );

    var sessionId = Uuid().v4();
    print("Before sessionId $sessionId");
    print("Before fingerprint $fingerprint");
    String prepareSign = await GoBridge.prepareSign(sessionId, base64Decode(fingerprint));

    print("prepare sign from go: $prepareSign");
    transaction_model.SignInfo signInfo = transaction_model.SignInfo.fromJson(
      json.decode(prepareSign),
    );

    signInfo.gamma1 = base64Encode(bigIntStringToBytes(signInfo.gamma1));
    signInfo.k1 = base64Encode(bigIntStringToBytes(signInfo.k1));
    signInfo.msgFingerprint = base64Encode(bigIntStringToBytes(signInfo.msgFingerprint));

    var prepareSignRes = await _transactionSwapRepository.prepareSign(signInfo, transaction);
    if (prepareSignRes.isSuccess) {
      print("Prepare sum: ${prepareSignRes.data![0]}");
      print("Prepare session id: ${prepareSignRes.data![1]}");
      signInfo.sum = prepareSignRes.data![0];
      signInfo.sessionId = sessionId;
      signInfo.sessionIdOnline = prepareSignRes.data![1];
      return Result<transaction_model.SignInfo>.success(signInfo);
    } else {
      return Result<transaction_model.SignInfo>.failure(prepareSignRes.error);
    }
  }

  Future<Result<String>> sendAsset(
      transaction_model.Transaction transaction,
      transaction_model.SignInfo signInfo,
      String userPin,
      ) async {
    print("transaction from ui ${transaction.rawEthereumTransaction.ethereumTx}");
    print("transaction amount from ui ${transaction.amount}");
    var invokeSignString = await GoBridge.invokeSign(
      signInfo.sessionId,
      base64Decode(signInfo.sum),
      utf8.encode(userPin),
    );
    final Map<String, dynamic> decoded = json.decode(invokeSignString);
    var tempSignInfo = transaction_model.SignInfo.fromJson(decoded);
    print("Decoded after invoke sign $invokeSignString");
    signInfo.gamma1g = transaction_model.Gamma1G(
      x: base64Encode(bigIntStringToBytes(tempSignInfo.gamma1g!.x)),
      y: base64Encode(bigIntStringToBytes(tempSignInfo.gamma1g!.y)),
      curve: transaction_model.CurveType.CURVE_SECP256K1.toString(),
    );
    signInfo.w1 = base64Encode(bigIntStringToBytes(tempSignInfo.w1));
    signInfo.delta1 = base64Encode(bigIntStringToBytes(tempSignInfo.delta1));
    signInfo.k1 = base64Encode(bigIntStringToBytes(tempSignInfo.k1));
    var signInfoRound2 = await _transactionSwapRepository.invokeSign(signInfo, transaction);
    var combineSignatureString = await GoBridge.combineSignature(
      signInfo.sessionId,
      base64Decode(signInfoRound2.data!.sum),
      base64Decode(signInfoRound2.data!.gamma1g!.x),
    );
    print("Round3 string: $combineSignatureString");
    final round3Decoded = jsonDecode(combineSignatureString);
    signInfoRound2.data!.s1 = base64Encode(bigIntStringToBytes(round3Decoded['s1']));
    signInfoRound2.data!.sessionIdOnline = signInfo.sessionIdOnline;
    var signatureResult = await _transactionSwapRepository.combineSignature(
      signInfoRound2.data!,
      transaction,
    );
    if (!signatureResult.isSuccess) {
      return Result<String>.failure(
        ApiError(
          statusCode: signatureResult.error!.statusCode,
          message: signatureResult.error!.message,
        ),
      );
    }
    transaction.rawEthereumTransaction.ethereumTx.remove('r');
    transaction.rawEthereumTransaction.ethereumTx.remove('s');
    transaction.rawEthereumTransaction.ethereumTx.remove('v');
    transaction.rawEthereumTransaction.ethereumTx.addAll({
      'r': toEthereumHex(bytesToBigInt(base64Decode(signatureResult.data!.r))),
      's': toEthereumHex(bytesToBigInt(base64Decode(signatureResult.data!.s))),
      'v': toEthereumHex(
        bytesToBigInt(base64Decode(signatureResult.data!.v)) + BigInt.from(1234 * 2 + 35),
      ),
    });
    print(
      "v value from http: ${(bytesToBigInt(base64Decode(signatureResult.data!.v)) + BigInt.from(1234 * 2 + 35)).toString()}",
    );
    print('byte to bigInt ${toEthereumHex(bytesToBigInt(base64Decode(signatureResult.data!.v)))}');
    print('bigInt value: ${bytesToBigInt(base64Decode(signatureResult.data!.v))}');
    var sendAssetRes = await _transactionSwapRepository.sendNative(signInfo, transaction);
    return sendAssetRes;
  }
}
