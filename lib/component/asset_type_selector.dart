import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:flutter/material.dart';

class TokenAssetSelector extends StatelessWidget {
  final String assetName;
  final String assetSymbol;
  final String assetBalance;
  final String balance;
  final Icon? assetIcon;

  const TokenAssetSelector({
    super.key,
    required this.assetName,
    required this.assetSymbol,
    required this.assetBalance,
    required this.balance,
    this.assetIcon = const Icon(Icons.monetization_on),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ethereum Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: assetIcon,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    assetSymbol,
                    softWrap: true, // Allows text to wrap
                    overflow: TextOverflow.ellipsis, // Or ellipsis/fade
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 50,
                  child: Text(
                    assetSymbol,
                    softWrap: true, // Allows text to wrap
                    overflow: TextOverflow.ellipsis, // Or ellipsis/fade
                    maxLines: 1,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$$balance',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    assetBalance,
                    softWrap: true, // Allows text to wrap
                    overflow: TextOverflow.ellipsis, // Or ellipsis/fade
                    maxLines: 1,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      assetSymbol,
                      softWrap: true, // Allows text to wrap
                      overflow: TextOverflow.ellipsis, // Or ellipsis/fade
                      maxLines: 1,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          Icon(Icons.chevron_right, color: Colors.grey, size: 24),
        ],
      ),
    );
  }
}

class NftAssetSelector extends StatelessWidget {
  final NftItem nftItem;

  const NftAssetSelector({super.key, required this.nftItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ethereum Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Icon(Icons.token),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    nftItem.name,
                    softWrap: true, // Allows text to wrap
                    overflow: TextOverflow.ellipsis, // Or ellipsis/fade
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 50,
                  child: Text(
                    nftItem.symbol,
                    softWrap: true, // Allows text to wrap
                    overflow: TextOverflow.ellipsis, // Or ellipsis/fade
                    maxLines: 1,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.chevron_right, color: Colors.grey, size: 24),
        ],
      ),
    );
  }
}
