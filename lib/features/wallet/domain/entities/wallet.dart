import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:digital_asset_flutter/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:flutter/foundation.dart';

class Wallet {
  String id; // UUID
  String walletId; // UUID
  String userId; // User email
  String networkId; // UUID
  String networkName; // e.g. Ethereum, Bitcoin
  String networkSymbol; // e.g. ETH, BTC
  String address; // Wallet address (from public key)
  String publicKey; // Public key
  DateTime? createdAt; // Wallet creation time
  DateTime? updatedAt; // Last update time
  String status; // Wallet status
  String accountKey; // Key used for share key phase
  String version; // Version of account key
  String walletName; // User-given name for the wallet
  List<AssetBalance>? assetBalances;
  List<NftItem>? nftItems;

  Wallet({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.networkId,
    required this.networkName,
    required this.networkSymbol,
    required this.address,
    required this.publicKey,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.accountKey,
    required this.version,
    required this.walletName,
    required this.assetBalances,
  });
}

class ShareKeyData {
  final String id;
  final String p10;
  final String p12;
  final String p21;

  ShareKeyData({required this.id, required this.p10, required this.p12, required this.p21});

  factory ShareKeyData.fromJson(Map<String, dynamic> json) {
    return ShareKeyData(id: json['id'], p10: json['p10'], p12: json['p12'], p21: json['p21']);
  }

  static Uint8List _bigIntToBytes(BigInt number) {
    final hexStr = number.toRadixString(16);
    final evenLengthHex = hexStr.length.isOdd ? '0$hexStr' : hexStr;
    return Uint8List.fromList(hex.decode(evenLengthHex));
  }
}

class WalletProvider with ChangeNotifier {
  Wallet? _wallet;
  List<Wallet> _listWallet = [];

  Wallet? get wallet => _wallet;

  List<Wallet> get listWallet => _listWallet;

  int _walletIndex = 0;

  int get walletIndex => _walletIndex;

  void setWallet(Wallet wallet) {
    _wallet = wallet;
    notifyListeners();
  }

  void setWalletIndexValue(int index) {
    _walletIndex = index;
    notifyListeners();
  }

  void setListWallets(List<Wallet> listWallet) {
    _listWallet = listWallet;
    notifyListeners();
  }

  void updateValuation(WalletUsecases walletUsecsae) {
    Timer.periodic(Duration(seconds: 5), (_) async {
      await walletUsecsae.updateValuation(_wallet!);
      notifyListeners();
    });
  }

  List<AssetBalance> getAssetByType(String assetType) {
    List<AssetBalance> res = [];
    for (int i = 0; i < _wallet!.assetBalances!.length; i++) {
      if (assetType == "TOKEN") {
        if (_wallet!.assetBalances![i].assetType == "COIN" ||
            _wallet!.assetBalances![i].assetType == "TOKEN") {
          res.add(_wallet!.assetBalances![i]);
        }
      } else if (_wallet!.assetBalances![i].assetType == assetType) {
        res.add(_wallet!.assetBalances![i]);
      }
    }
    return res;
  }

  List<NftItem>? getNftItem() {
    return _wallet!.nftItems;
  }
}

class AssetBalance {
  String id;
  String assetId;
  String assetSymbol;
  String walletId;
  String balance;
  String assetBalance;
  String assetType;
  double price;
  String currency;
  DateTime? updatedAt;
  double last24hChange;
  int decimals;

  AssetBalance({
    required this.id,
    required this.assetId,
    required this.assetSymbol,
    required this.walletId,
    required this.balance,
    required this.assetType,
    required this.currency,
    required this.updatedAt,
    required this.last24hChange,
    required this.price,
    required this.assetBalance,
    required this.decimals,
  });

  @override
  String toString() {
    return 'AssetBalance('
        'id: $id, '
        'assetId: $assetId, '
        'assetSymbol: $assetSymbol, '
        'walletId: $walletId, '
        'balance: $balance, '
        'assetBalance: $assetBalance, '
        'assetType: $assetType, '
        'price: $price, '
        'currency: $currency, '
        'updatedAt: ${updatedAt?.toIso8601String()}, '
        'last24hChange: $last24hChange'
        ')';
  }
}

AssetBalance defaultAssetBalance() {
  return AssetBalance(
    id: '',
    assetId: '',
    assetSymbol: '',
    walletId: '',
    balance: '0',
    assetBalance: '0',
    assetType: '',
    price: 0.0,
    currency: '',
    updatedAt: null,
    last24hChange: 0.0,
    decimals: 0,
  );
}

class NftItem {
  final String tokenId;
  final String contractAddress;
  final String name;
  final String symbol;
  final String owner;
  final String imageUrl;
  final String description;
  final String networkName;
  final NftAttributes attributes;

  NftItem({
    required this.tokenId,
    required this.contractAddress,
    required this.name,
    required this.symbol,
    required this.owner,
    required this.imageUrl,
    required this.description,
    required this.networkName,
    required this.attributes,
  });

  factory NftItem.fromJson(Map<String, dynamic> json) {
    return NftItem(
      tokenId: json['tokenId'],
      contractAddress: json['contractAddress'],
      name: json['name'],
      symbol: json['symbol'],
      owner: json['owner'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      networkName: json['networkName'],
      attributes: NftAttributes.fromJson(json['attributes']),
    );
  }
}

class NftAttributes {
  final String donationAmount;
  final String projectId;
  final String projectName;
  final String projectOwner;
  final String rarity;

  NftAttributes({
    required this.donationAmount,
    required this.projectId,
    required this.projectName,
    required this.projectOwner,
    required this.rarity,
  });

  factory NftAttributes.fromJson(Map<String, dynamic> json) {
    return NftAttributes(
      donationAmount: json['donationAmount'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      projectOwner: json['projectOwner'],
      rarity: json['rarity'],
    );
  }
}
