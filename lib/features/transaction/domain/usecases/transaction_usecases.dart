import 'dart:convert';
import 'dart:typed_data';

import 'package:digital_asset_flutter/core/helper/dart_ffi.dart';
import 'package:digital_asset_flutter/core/helper/helper.dart';
import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart'
    as transaction_model;
import 'package:digital_asset_flutter/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:rlp/rlp.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

Future<String> createTransactionFingerprint({
  required int chainId,
  required int nonce,
  required to,
  required BigInt value,
  required BigInt gasPrice,
  required BigInt gas,
  required Uint8List data,
}) async {
  // Create the unsigned transaction
  final tx = Transaction(
    nonce: nonce,
    gasPrice: EtherAmount.inWei(gasPrice),
    maxGas: 60000,
    data: data,
  );
  print(
    "from finger print nonce: $nonce, gas: ${gas.toString()},gasPrice: ${gasPrice.toString()},value: ${value.toString()},chainId: ${BigInt.from(chainId)},to: ${to.toString()}",
  );
  // Use EIP-155 to hash the transaction for signing
  final rlpEncoded = Rlp.encode([
    hexToInt('0x5'),
    hexToInt('0x3b9aca00'),
    hexToInt('0x5208'),
    to.addressBytes,
    hexToInt('0x2386f26fc10000'),
    data,
    hexToInt('0x4d2'),
    0, // r
    0, // s
  ]);

  // Hash it using keccak256
  final transactionHash = keccak256(rlpEncoded);
  return base64Encode(transactionHash);
}

Uint8List encodeBigInt(BigInt number) {
  if (number == BigInt.zero) return Uint8List(0);

  var _number = number;
  final result = <int>[];
  while (_number > BigInt.zero) {
    result.insert(0, (_number & BigInt.from(0xff)).toInt());
    _number = _number >> 8;
  }
  return Uint8List.fromList(result);
}

class TransactionUsecase {
  TransactionUsecase({required TransactionRepository transactionRepository})
    : _transactionRepository = transactionRepository;

  final TransactionRepository _transactionRepository;

  Future<Result<transaction_model.SignInfo>> prepareSign(
    transaction_model.Transaction transaction,
  ) async {
    Result<transaction_model.Transaction> rawTransaction = await _transactionRepository
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

    var prepareSignRes = await _transactionRepository.prepareSign(signInfo, transaction);
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
    var signInfoRound2 = await _transactionRepository.invokeSign(signInfo, transaction);
    var combineSignatureString = await GoBridge.combineSignature(
      signInfo.sessionId,
      base64Decode(signInfoRound2.data!.sum),
      base64Decode(signInfoRound2.data!.gamma1g!.x),
    );
    print("Round3 string: $combineSignatureString");
    final round3Decoded = jsonDecode(combineSignatureString);
    signInfoRound2.data!.s1 = base64Encode(bigIntStringToBytes(round3Decoded['s1']));
    signInfoRound2.data!.sessionIdOnline = signInfo.sessionIdOnline;
    var signatureResult = await _transactionRepository.combineSignature(
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
    var sendAssetRes = await _transactionRepository.sendNative(signInfo, transaction);
    return sendAssetRes;
  }

  Future<Result<List<transaction_model.TransactionHistoryData>>> getTxHistory(
    String walletAddress,
  ) async {
    var res = await _transactionRepository.getHistory(walletAddress);

    if (res.isSuccess) {
      print("Doing from tx history usecase");
      for (int i = 0; i < res.data!.length; i++) {
        res.data![i].value = convertWithDecimal(res.data![i].value, res.data![i].tokenDecimal);
        res.data![i].fee = convertWithDecimal(res.data![i].fee, res.data![i].tokenDecimal);
        if (res.data![i].tokenType == "COIN" && res.data![i].tokenSymbol == "ETH") {
          res.data![i].value = convertWithDecimal(res.data![i].value, 18);
          res.data![i].fee = convertWithDecimal(res.data![i].fee, 18);
        }
        if (res.data![i].timestamp != null) {
          res.data![i].timeAgo = getTimeAgo(res.data![i].timestamp!);
        }
      }
    }
    return res;
  }

  Future<Result<transaction_model.TransactionSwap>> getQuote(
    transaction_model.TransactionSwap txSwap,
  ) async {
    var res = await _transactionRepository.getQuote(txSwap);
    if (res.isSuccess) {
      txSwap.toAmount = convertWithDecimal(double.parse(res.data!.toAmount), txSwap.toAsset!.decimals).toString();
      txSwap.estimatedFee = res.data!.estimatedFee;
      txSwap.rate = res.data!.rate;
      txSwap.expirationTimestamp = res.data!.expirationTimestamp;
      txSwap.expirationTimestamp = res.data!.expirationTimestamp;
      txSwap.depositAddress = res.data!.depositAddress;
      return Result.success(txSwap);
    }
    return res;
  }
}

/// Converts a base-10 BigInt string to a byte array (Uint8List)
Uint8List bigIntStringToBytes(String value) {
  final bigInt = BigInt.parse(value, radix: 10);

  final bytes = _encodeBigInt(bigInt);
  return Uint8List.fromList(bytes);
}

/// Helper: Converts BigInt to bytes (unsigned big-endian)
List<int> _encodeBigInt(BigInt number) {
  if (number == BigInt.zero) return [0];

  final result = <int>[];
  var temp = number;

  while (temp > BigInt.zero) {
    result.insert(0, (temp & BigInt.from(0xff)).toInt());
    temp = temp >> 8;
  }

  return result;
}

BigInt bytesToBigInt(Uint8List bytes) {
  BigInt result = BigInt.zero;
  for (var byte in bytes) {
    result = (result << 8) | BigInt.from(byte);
  }
  return result;
}

String toEthereumHex(BigInt bigInt) {
  // Convert BigInt to hexadecimal string
  String hex = bigInt.toRadixString(16);

  // Remove any leading zeros (not necessary here, but good practice)
  hex = hex.replaceFirst(RegExp(r'^0+'), '');

  // Ensure at least '0' is present
  if (hex.isEmpty) {
    hex = '0';
  }

  // Add '0x' prefix
  return '0x$hex';
}

String ethToWeiString(String ethValueStr) {
  final ethValue = double.parse(ethValueStr);
  final wei = BigInt.from(ethValue * 1e18);
  return wei.toString(); // return as decimal string
}
