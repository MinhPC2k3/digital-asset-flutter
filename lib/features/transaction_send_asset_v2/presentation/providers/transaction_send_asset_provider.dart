import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/data/datasource/network/transaction_send_asset.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/repositories/transaction_send_asset_repository.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/usecases/transaction_send_asset_usecase.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:flutter/foundation.dart' as provider;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/helper/helper.dart';

class TransactionSendAssetProvider extends provider.ChangeNotifier {
  late TransactionSendAssetRepository _repository;
  late TransactionSendAssetUsecase _usecase;
  Asset? _selectedAsset;
  NFT? _selectedNft;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isValidAddress = false;
  bool isValidAmount = false;

  Asset? get selectedAsset => _selectedAsset;

  NFT? get selectedNft => _selectedNft;

  void selectAsset(Asset asset) {
    _selectedAsset = asset;
    _selectedNft = null;
  }

  void selectNft(NFT nft) {
    _selectedNft = nft;
    _selectedAsset = null;
  }

  void validateAddress(String address) {
    // Simple Ethereum address validation (starts with 0x and 42 characters)
    isValidAddress = address.startsWith('0x') && address.length == 42;
    notifyListeners();
  }

  void validateAmount(String amountInput) {
    try {
      var amount = double.parse(amountInput);
      isValidAmount = amount > 0;
    } catch (e) {
      isValidAmount = false;
    }
    notifyListeners();
  }

  void setMaxAmount() {
    if (_selectedAsset != null) {
      if (_selectedAsset!.balance == '') {
        amountController.text = '0';
      } else {
        amountController.text = _selectedAsset!.balance;
      }
    }
    validateAmount(amountController.text);
  }

  bool get canProceed => isValidAddress && (isValidAmount || selectedNft != null);

  @override
  void dispose() {
    addressController.dispose();
    amountController.dispose();
    super.dispose();
  }

  TransactionSendAssetProvider() {
    _repository = TransactionSendAssetRepositoryImpl(http.Client());
    _usecase = TransactionSendAssetUsecase(repository: _repository);
  }

  String? _error;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Transaction? _createdTransaction;

  Transaction get createdTransaction => _createdTransaction!;

  Future<Result<SignInfo>> prepareSendAssetTransaction(
    String userId,
    String walletId,
    String networkName,
    Asset? asset,
    NFT? nft,
    String amount,
    String receiverAddress,
  ) async {
    _isLoading = true;
    notifyListeners();
    _createdTransaction = Transaction(
      userId: userId,
      walletId: walletId,
      amount: amount,
      receiverAddress: receiverAddress,
      blockchainType: null,
      networkName: networkName,
      transactionType: null,
      assetId: '',
      tokenId: '',
    );
    if (asset != null) {
      _createdTransaction!.assetId = asset.assetId;
    } else if (nft != null) {
      _createdTransaction!.assetId = nft.assetId;
      _createdTransaction!.tokenId = nft.tokenId;
    } else {
      return Result.failure(
        ApiError(message: "nft and asset you want to send is empty", statusCode: 400),
      );
    }
    _createdTransaction = addTransactionTypeV2(_createdTransaction!);
    var signResponse = await _usecase.prepareSign(_createdTransaction!);
    _isLoading = false;
    notifyListeners();

    return signResponse;
  }

  String getNetworkFeeInAsset() => '0 ETH';

  String getNetworkFeeInFiat() => '0 USD';
}
