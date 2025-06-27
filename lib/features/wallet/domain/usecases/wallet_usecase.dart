import 'dart:convert';
import 'dart:typed_data';

import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/core/helper/dart_ffi.dart';
import 'package:digital_asset_flutter/features/auth/domain/entities/user.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:uuid/uuid.dart';

class WallerUsecases {
  WallerUsecases({required WalletRepository walletRepository})
    : _walletRepository = walletRepository;
  final WalletRepository _walletRepository;

  Future<Result<List<Wallet>>> getUserWallet(String userId) async {
    Result<List<Wallet>> listWallet = await _walletRepository.getUserWallet(userId);
    return listWallet;
  }

  Future<Result<Wallet>> createWallet(
    String userId,
    String walletName,
    String network,
    String walletPin,
  ) async {
    print("Doing...");
    Result<Wallet> wallet = await _walletRepository.createWallet(
      Wallet(
        id: '',
        walletId: '',
        userId: userId,
        networkId: '',
        networkName: network,
        networkSymbol: '',
        address: '',
        publicKey: '',
        createdAt: null,
        updatedAt: null,
        status: '',
        accountKey: '',
        version: '',
        walletName: walletName,
        assetBalances: null,
      ),
    );

    if (!wallet.isSuccess) {
      print("Shared key error: ${wallet.error!.message}");
      return wallet;
    }
    print("Key: ${wallet.data!.accountKey}");
    print("Object ${wallet.data!.networkName}, id: ${wallet.data!.networkId}");
    String result = await GoBridge.computeShareKey(
      Uuid().v4(),
      wallet.data!.accountKey,
      Uint8List.fromList(utf8.encode(walletPin)),
    );
    print("Shared key data: $result");
    ShareKeyData shareKeyData = ShareKeyData.fromJson(jsonDecode(result));

    BigInt p10BigInt = BigInt.parse(shareKeyData.p10);
    Uint8List p10 = bigIntToBytes(p10BigInt);

    BigInt p12BigInt = BigInt.parse(shareKeyData.p12);
    Uint8List p12 = bigIntToBytes(p12BigInt);

    BigInt p21BigInt = BigInt.parse(shareKeyData.p21);
    Uint8List p21 = bigIntToBytes(p21BigInt);

    Result<Wallet> sharedKeyWallet = await _walletRepository.shareKey(
      wallet.data!,
      base64Encode(p10),
      base64Encode(p12),
      base64Encode(p21),
    );

    if (!sharedKeyWallet.isSuccess) {
      print("Shared key error: ${sharedKeyWallet.error!.message}");
      return sharedKeyWallet;
    }

    return wallet;
  }

  Future<Result<Wallet>> getWalletAssetBalances(Wallet wallet) async {
    Result<List<AssetBalance>> assetBalances = await _walletRepository.getAssetBalances(wallet.id);
    if (!assetBalances.isSuccess) {
      return Result.failure(assetBalances.error);
    }
    wallet.assetBalances = assetBalances.data!;
    for (int i = 0; i < wallet.assetBalances!.length; i++) {
      Result<AssetBalance> valuation = await _walletRepository.getAssetValuation(
        wallet.id,
        wallet.assetBalances![i],
      );
      if (!valuation.isSuccess) {
        return Result.failure(valuation.error);
      }
      wallet.assetBalances![i] = valuation.data!;
      if (wallet.assetBalances![i].assetId == 'asset-eth-0001') {
        wallet.assetBalances![i].balance = (weiToEth(wallet.assetBalances![i].assetBalance) *
                wallet.assetBalances![i].price)
            .toStringAsFixed(2);
      }
      print("AssetBalance from usecase: ${wallet.assetBalances![i].toString()}");
    }
    return Result.success(wallet);
  }

  Future<Result<String>> updateValuation(Wallet wallet) async {
    print("Update valuation after 5s interval");
    if (wallet.assetBalances != null) {
      for (int i = 0; i < wallet.assetBalances!.length; i++) {
        var assetBalance = await _walletRepository.getAssetValuation(
          wallet.id,
          wallet.assetBalances![i],
        );
        if (!assetBalance.isSuccess) {
          return Result.failure(
            ApiError(
              statusCode: assetBalance.error!.statusCode,
              message: "Error when get update valuation",
            ),
          );
        }
        wallet.assetBalances![i] = assetBalance.data!;
        wallet.assetBalances![i].balance = (weiToEth(wallet.assetBalances![i].assetBalance) *
                wallet.assetBalances![i].price)
            .toStringAsFixed(2);
      }
    }

    return Result.success("Update valuation success");
  }
}

Uint8List bigIntToBytes(BigInt number) {
  // Get bytes in big-endian order
  final bytes = number.toRadixString(16).padLeft(64, '0'); // pad for full 32 bytes
  final byteList = <int>[];

  for (var i = 0; i < bytes.length; i += 2) {
    byteList.add(int.parse(bytes.substring(i, i + 2), radix: 16));
  }

  return Uint8List.fromList(byteList);
}

double weiToEth(String weiString) {
  const double weiInEth = 1e18;
  return BigInt.parse(weiString).toDouble() / weiInEth;
}
