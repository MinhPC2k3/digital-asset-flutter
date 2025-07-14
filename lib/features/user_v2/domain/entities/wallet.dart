import 'asset.dart';
import 'package:convert/convert.dart';

class Wallet {
  String walletId;
  String walletName;
  String address;
  String networkName;
  List<Asset> assets;
  List<NFT>? nfts;
  double totalValue;
  String userId;
  String walletKey;
  String version;

  Wallet({
    required this.walletId,
    required this.walletName,
    required this.address,
    required this.networkName,
    required this.assets,
    required this.nfts,
    required this.totalValue,
    required this.userId,
    required this.walletKey,
    required this.version,
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
}