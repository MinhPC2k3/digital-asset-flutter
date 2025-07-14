import 'dart:convert';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/user_v2/data/models/wallet_dto.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/repositories/create_wallet_repository.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/api_constans.dart';

class CreateWalletRepositoryImpl implements CreateWalletRepository {
  final http.Client client;

  CreateWalletRepositoryImpl({required this.client});

  @override
  Future<Result<Wallet>> createWallet(Wallet wallet) async {
    String url = ApiEndpoints.createWallet;
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, dynamic> reqBody = {
      "metadata": {
        "request_id": Uuid().v4(),
        "request_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
        "client_id": "mobile-app",
        "signature": {
          "sa_type": "SIGNATURE",
          "s": "optional-signature-string",
          "b": "c2lnbmF0dXJlLWJ5dGVz", // base64 of signature bytes
        },
        "version": 1,
      },
      "data": {
        "user_id": wallet.userId,
        "network_id": wallet.networkName,
        "wallet_name": wallet.walletName,
      },
    };

    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );
    print("Create wallet response: ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);

      final dynamic dataList = decoded['data'];
      WalletDTO walletDTO = WalletDTO.fromJson(dataList);
      wallet.walletKey = walletDTO.walletKey;
      wallet.version = walletDTO.version;
      wallet.walletId = walletDTO.walletId;
      return Result.success(wallet);
    } else {
      final json = jsonDecode(res.body);
      print("Error when create wallet: $json");
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<Wallet>> shareKey(Wallet wallet, String p10, String p12, String p21) async {
    String url = ApiEndpoints.shareKey;
    Map<String, String> headers = {"Content-type": "application/json"};
    final Map<String, dynamic> reqBody = {
      "metadata": {
        "request_id": Uuid().v4(),
        "request_time": DateTime.now().millisecondsSinceEpoch ~/ 1000,
        "client_id": "mobile-app",
        "signature": {
          "sa_type": "SIGNATURE",
          "s": "optional-signature-string",
          "b": "c2lnbmF0dXJlLWJ5dGVz", // base64 of signature bytes
        },
        "version": 1,
      },
      "data": {
        "wallet_id": wallet.walletId,
        "user_id": wallet.userId,
        "network_id": wallet.networkName,
        "share_key_data": {
          "p10": p10,
          "p12": p12,
          "p21": p21,
          "wallet_key_version": wallet.version,
        },
      },
    };
    print("Share key request: $reqBody");
    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );

    if (res.statusCode == 200) {
      return Result.success(wallet);
    } else {
      final json = jsonDecode(res.body);
      final state = json['state'] ?? {};
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: state['message'] ?? 'Lỗi không xác định'),
      );
    }
  }
}
