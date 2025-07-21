import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:flutter/material.dart';

class SelectedAssetInfo extends StatelessWidget {
  final Asset? selectedAsset;
  final NFT? selectedNft;
  final bool isSelectedNft;

  const SelectedAssetInfo({
    super.key,
    required this.selectedAsset,
    required this.selectedNft,
    required this.isSelectedNft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF627EEA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.currency_bitcoin, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                selectedAsset != null
                    ? Text(
                      selectedAsset!.symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : Container(),
                selectedNft != null
                    ? Text(
                      selectedNft!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : Container(),
                selectedAsset != null
                    ? Text(
                      'Balance: ${selectedAsset!.balance} ${selectedAsset!.symbol}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    )
                    : Container(),
                selectedNft != null
                    ? Text(
                      selectedNft!.collection,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
