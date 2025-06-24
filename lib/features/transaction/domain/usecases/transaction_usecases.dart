import 'dart:convert';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/core/helper/dart_ffi.dart';
import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart'
    as transaction_model;
import 'package:digital_asset_flutter/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:digital_asset_flutter/core/helper/helper.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/crypto.dart';

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:rlp/rlp.dart';
import 'package:convert/convert.dart';

Future<String> createTransactionFingerprint({
  required int chainId,
  required int nonce,
  required EthereumAddress to,
  required BigInt value,
  required BigInt gasPrice,
  required Uint8List data,
}) async {
  // Create the unsigned transaction
  final tx = Transaction(
    to: to,
    nonce: nonce,
    value: EtherAmount.inWei(value),
    gasPrice: EtherAmount.inWei(gasPrice),
    maxGas: 60000,
    data: data,
  );

  // Use EIP-155 to hash the transaction for signing
  final rlpEncoded = Rlp.encode([
    Rlp.encode(nonce),
    Rlp.encode(gasPrice),
    Rlp.encode(BigInt.from(60000)),
    to.addressBytes,
    Rlp.encode(value),
    data,
    Rlp.encode(BigInt.from(chainId)), // v (EIP-155)
    Uint8List(0), // r
    Uint8List(0), // s
  ]);

  final fingerprint = keccak256(rlpEncoded);
  return base64Encode(fingerprint);
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
    var fingerprint = await createTransactionFingerprint(
      chainId: int.parse(rawTransaction.data!.rawEthereumTransaction.chainId),
      nonce:
          covertStringToBigInt(
            rawTransaction.data!.rawEthereumTransaction.ethereumTx['nonce'],
          ).toInt(),
      to: EthereumAddress.fromHex(rawTransaction.data!.rawEthereumTransaction.toAddress),
      value: covertStringToBigInt(rawTransaction.data!.rawEthereumTransaction.ethereumTx['value']),
      gasPrice: covertStringToBigInt(
        rawTransaction.data!.rawEthereumTransaction.ethereumTx['gasPrice'],
      ),
      data: Uint8List(0),
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
      'v': toEthereumHex(bytesToBigInt(base64Decode(signatureResult.data!.v))+BigInt.from(1234*2+35)),
    });
    print("v value from http: ${(bytesToBigInt(base64Decode(signatureResult.data!.v))+BigInt.from(1234*2+35)).toString()}");
    print('byte to bigInt ${toEthereumHex(bytesToBigInt(base64Decode(signatureResult.data!.v)))}');
    print('bigInt value: ${bytesToBigInt(base64Decode(signatureResult.data!.v))}');
    var sendAssetRes = await _transactionRepository.sendNative(signInfo, transaction);
    return sendAssetRes;
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