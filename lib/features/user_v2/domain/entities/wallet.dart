import 'asset.dart';

class Wallet {
  final String walletId;
  final String walletName;
  final String address;
  final String networkName;
  final List<Asset> assets;
  final List<NFT>? nfts;
  final double totalValue;

  Wallet({
    required this.walletId,
    required this.walletName,
    required this.address,
    required this.networkName,
    required this.assets,
    required this.nfts,
    required this.totalValue,
  });
}
