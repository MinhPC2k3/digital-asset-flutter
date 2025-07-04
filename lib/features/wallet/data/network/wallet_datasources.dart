import 'dart:convert';

import 'package:digital_asset_flutter/core/constants/api_constans.dart';
import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/wallet/data/DTO/wallet_dto.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class WalletRepositoryImpl implements WalletRepository {
  final http.Client client;

  WalletRepositoryImpl(this.client);

  @override
  Future<Result<Wallet>> createWallet(Wallet wallet) async {
    print("Wallet creating...");
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
    print("Request body: $reqBody");
    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);

      final dynamic dataList = decoded['data'];
      WalletDto walletDTO = WalletDto.fromJson(dataList);
      walletDTO.userId = wallet.userId;
      walletDTO.network = wallet.networkName;
      walletDTO.walletName = wallet.walletName;
      return Result.success(walletDTO.toDomain());
    } else {
      final json = jsonDecode(res.body);
      print("Error when create wallet: $json");
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: json['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<List<Wallet>>> getUserWallet(String userId) async {
    String url = '${ApiEndpoints.userBaseUrl}/$userId/wallets';
    Map<String, String> headers = {"Content-type": "application/json"};
    http.Response res = await client.get(Uri.parse(url), headers: headers);
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);

      final dynamic dataList = decoded['data'];
      if (dataList['wallets'] != null) {
        final List<dynamic> listWallets = dataList['wallets'];
        print("List: ${listWallets}");
        final wallets = listWallets.map((item) => WalletDto.fromJson(item).toDomain()).toList();
        return Result.success(wallets);
      }
      return Result.success([]);
    } else {
      final json = jsonDecode(res.body);
      final state = json['state'] ?? {};
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: state['message'] ?? 'Lỗi không xác định'),
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
        "wallet_id": wallet.id,
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
      final Map<String, dynamic> decoded = json.decode(res.body);

      final dynamic dataList = decoded['data'];
      final wallet = WalletDto.fromJson(dataList).toDomain();
      return Result.success(wallet);
    } else {
      final json = jsonDecode(res.body);
      final state = json['state'] ?? {};
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: state['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<List<AssetBalance>>> getAssetBalances(String walletId) async {
    String url = '${ApiEndpoints.walletCoreBaseUrl}/$walletId/asset-balances';
    Map<String, String> headers = {"Content-type": "application/json"};
    http.Response res = await client.get(Uri.parse(url), headers: headers);
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);

      final dynamic dataList = decoded['data'];
      if (dataList['balances'] != null) {
        final List<dynamic> listAssetBalances = dataList['balances'];
        print("List asset balances: $listAssetBalances");
        final assetBalances =
            listAssetBalances.map((item) => AssetBalanceDTO.fromJson(item).toDomain()).toList();
        return Result.success(assetBalances);
      }
      return Result.success([]);
    } else {
      final json = jsonDecode(res.body);
      final state = json['state'] ?? {};
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: state['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<AssetBalance>> getAssetValuation(
    String walletId,
    AssetBalance assetBalances,
  ) async {
    String url =
        '${ApiEndpoints.walletCoreBaseUrl}/$walletId/assets/${assetBalances.assetId}/valuation';
    Map<String, String> headers = {"Content-type": "application/json"};
    http.Response res = await client.get(Uri.parse(url), headers: headers);
    // print("Get valuation response ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);

      final dynamic data = decoded['data'];
      if (data != null) {
        return Result.success(PriceValuationDTO.fromJson(data).toDomain(assetBalances));
      }
      return Result.failure(ApiError(statusCode: 400, message: "Empty asset valutaion"));
      ;
    } else {
      final json = jsonDecode(res.body);
      final state = json['state'] ?? {};
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: state['message'] ?? 'Lỗi không xác định'),
      );
    }
  }

  @override
  Future<Result<List<NftItem>>> getWalletNft(
    String walletId,
    String assetId,
    String networkName,
  ) async {
    String url = ApiEndpoints.nftList;
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
      "data": {"wallet_id": walletId, "asset_id": assetId, "network_name": networkName},
    };
    http.Response res = await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(reqBody),
    );
    // print("Get valuation response ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);

      final dynamic data = decoded['data'];
      if (data != null) {
        if (data['nfts'] != null) {
          final List<dynamic> listNfts = data['nfts'];
          print("List nfts: $listNfts");
          print("List nfts length: ${listNfts.length}");
          final nftItems = listNfts.map((item) => NftItem.fromJson(item)).toList();
          return Result.success(nftItems);
        }
      }
      return Result.success([]);
    } else {
      final json = jsonDecode(res.body);
      final state = json['state'] ?? {};
      return Result.failure(
        ApiError(statusCode: res.statusCode, message: state['message'] ?? 'Lỗi không xác định'),
      );
    }
  }
}
