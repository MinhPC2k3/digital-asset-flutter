import 'dart:convert';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/data/models/transaction_dto.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/repositories/transaction_send_asset_repository.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/api_constans.dart';

class TransactionSendAssetRepositoryImpl implements TransactionSendAssetRepository {
  final http.Client client;

  TransactionSendAssetRepositoryImpl(this.client);

  @override
  Future<Result<Transaction>> buildRawTransaction(Transaction transaction) async {
    String url = ApiEndpoints.buildRawTx;
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, dynamic> reqBody = {
      "metadata": {
        "request_id": Uuid().v4(),
        "request_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      "data": {
        "wallet_id": transaction.walletId,
        "amount": transaction.amount,
        "receiver_address": transaction.receiverAddress,
        "asset_id": transaction.assetId,
        "network_name": transaction.networkName,
        "tx_type": transaction.transactionType.toString().split('.').last,
        "extra_fields": {"tokenId": transaction.tokenId},
      },
    };
    print("Transaction v2 buildRawTransaction request: $reqBody");
    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );
    print("Transaction v2 buildRawTransaction Response: ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);
      final dynamic resMessage = decoded["state"];
      if (resMessage["code"] != null) {
        return Result.failure(
          ApiError(message: resMessage['message'] ?? 'Lỗi không xác định', statusCode: 400),
        );
      }
      RawTransactionDTO rawTransactionDTO = RawTransactionDTO.fromJson(decoded);
      return Result.success(rawTransactionDTO.toDomain(transaction));
    } else {
      final json = jsonDecode(res.body);
      print("Error when create wallet: $json");
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<List<String>>> prepareSign(SignInfo signInfo, Transaction transaction) async {
    String url = ApiEndpoints.prepareSign;
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, dynamic> reqBody = {
      "metadata": {
        "request_id": Uuid().v4(),
        "request_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      "data": {
        "k1": signInfo.k1,
        "gamma1": signInfo.gamma1,
        "msg_fingerprint": signInfo.msgFingerprint,
        "sign_context": {
          "wallet_id": transaction.walletId,
          "user_id": transaction.userId,
          "network_name": transaction.networkName,
        },
      },
    };
    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );
    print("Transaction v2 prepareSign request: ${reqBody}");
    print("Transaction v2 prepareSign Response: ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);
      final dynamic resMessage = decoded["state"];
      if (resMessage["code"] != null) {
        return Result.failure(
          ApiError(message: resMessage['message'] ?? 'Lỗi không xác định', statusCode: 400),
        );
      }
      final dynamic data = decoded["data"];
      List<String> result = [];
      result.add(data['sum']);
      result.add(data['sessionId']);
      return Result.success(result);
    } else {
      final json = jsonDecode(res.body);
      print("Error when create wallet: $json");
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<SignInfo>> invokeSign(SignInfo signInfo, Transaction transaction) async {
    String url = ApiEndpoints.invokeSign;
    print("Doing invoke....$url");
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, dynamic> reqBody = {
      "metadata": {
        "request_id": Uuid().v4(),
        "request_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      "data": {
        "delta1": signInfo.delta1,
        "k1": signInfo.k1,
        "w1": signInfo.w1,
        "session_id": signInfo.sessionIdOnline,
        "gamma1G": {
          "x": signInfo.gamma1g!.x,
          "y": signInfo.gamma1g!.y,
          "curve": signInfo.gamma1g!.curve.toString().split('.').last,
        },
        "sign_context": {
          "wallet_id": transaction.walletId,
          "user_id": transaction.userId,
          "network_name": transaction.networkName,
        },
      },
    };
    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );
    print("Request: ${jsonEncode(reqBody)}");
    print("Response: ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);
      print("invoke body response: $decoded");
      final dynamic resMessage = decoded["state"];
      if (resMessage["code"] != null) {
        return Result.failure(
          ApiError(message: resMessage['message'] ?? 'Lỗi không xác định', statusCode: 400),
        );
      }
      final dynamic data = decoded["data"];
      signInfo.sum = data['sum'];
      final dynamic ecPoint = data['R'];
      signInfo.gamma1g!.x = ecPoint['x'];
      signInfo.gamma1g!.y = ecPoint['y'];
      return Result.success(signInfo);
    } else {
      final json = jsonDecode(res.body);
      print("Error when create wallet: $json");
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<Signature>> combineSignature(SignInfo signInfo, Transaction transaction) async {
    String url = ApiEndpoints.combineSignature;
    print("Doing invoke....$url");
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, dynamic> reqBody = {
      "metadata": {
        "request_id": Uuid().v4(),
        "request_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      "data": {
        "s1": signInfo.s1,
        "session_id": signInfo.sessionIdOnline,
        "sign_context": {
          "wallet_id": transaction.walletId,
          "user_id": transaction.userId,
          "network_name": transaction.networkName,
        },
      },
    };
    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );
    print("Request: ${jsonEncode(reqBody)}");
    print("Response: ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);
      print("combine body response: $decoded");
      final dynamic resMessage = decoded["state"];
      if (resMessage["code"] != null) {
        return Result.failure(
          ApiError(message: resMessage['message'] ?? 'Lỗi không xác định', statusCode: 400),
        );
      }
      final dynamic data = decoded["data"];
      var signatureDTO = SignatureDTO.fromJson(data);
      return Result.success(signatureDTO.toDomain());
    } else {
      final json = jsonDecode(res.body);
      print("Error when create wallet: $json");
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<String>> sendNative(SignInfo signInfo, Transaction transaction) async {
    String url = ApiEndpoints.sendAsset;
    transaction.rawEthereumTransaction.ethereumTx.addAll({
      'chainId': "0x4d2",
      'maxPriorityFeePerGas': null,
      'maxFeePerGas': null,
    });
    print("Doing send native....$url");
    print("Transaction type ${transaction.transactionType}");
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, dynamic> reqBody = {
      "metadata": {
        "request_id": Uuid().v4(),
        "request_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      "data": {
        "wallet_id": transaction.walletId,
        "user_id": transaction.userId,
        "network_name": transaction.networkName,
        "asset_id": transaction.assetId,
        "tx_type": transaction.transactionType.toString().split('.').last,
        "signed_transaction": {"ethereumTx": transaction.rawEthereumTransaction.ethereumTx},
        "amount": transaction.amount,
      },
    };
    print("Request: ${jsonEncode(reqBody)}");
    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );

    print("Transaction v2 sendNative Response: ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);
      print("combine body response: $decoded");
      final dynamic resMessage = decoded["state"];
      if (resMessage["code"] != null) {
        return Result.failure(
          ApiError(message: resMessage['message'] ?? 'Lỗi không xác định', statusCode: 400),
        );
      }
      final dynamic data = decoded["data"];
      return Result.success(data['txHash']);
    } else {
      final json = jsonDecode(res.body);
      print("Error when create wallet: $json");
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }
}
