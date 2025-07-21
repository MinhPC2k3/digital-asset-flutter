import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:flutter/material.dart';

class AssetSelector extends StatelessWidget {
  final Asset asset;
  final Icon? assetIcon;

  const AssetSelector({
    super.key,
    required this.asset,
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
                    asset.symbol,
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
                    asset.symbol,
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
                '\$${asset.valuationUsd}',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    asset.balance,
                    softWrap: true, // Allows text to wrap
                    overflow: TextOverflow.ellipsis, // Or ellipsis/fade
                    maxLines: 1,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      asset.symbol,
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
  final NFT nftItem;

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
                    nftItem.collection,
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
