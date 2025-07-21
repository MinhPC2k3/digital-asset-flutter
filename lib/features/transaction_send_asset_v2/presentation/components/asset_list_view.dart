import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/components/asset_selector.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/providers/transaction_send_asset_provider.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/choose_address_amount.dart';

class AssetListView extends StatelessWidget {
  final List<Asset>? listAssets;
  final List<NFT>? listNfts;
  final bool isNFT;

  const AssetListView({
    super.key,
    required this.listAssets,
    required this.isNFT,
    required this.listNfts,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<TransactionSendAssetProvider>(context);
    if (isNFT) {
      return ListView.builder(
        itemCount: listNfts?.length ?? 0,
        itemBuilder:
            (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: GestureDetector(
                onTap:
                    () => {
                      provider.selectNft(listNfts![index]),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChooseAddressAndAmount(
                                selectedAsset: null,
                                selectedNft: listNfts![index],
                                isNftSelected: true,
                              ),
                        ),
                      ),
                    },
                child: NftAssetSelector(nftItem: listNfts![index]),
              ),
            ),
      );
    }

    return ListView.builder(
      itemCount: listAssets?.length ?? 0,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: GestureDetector(
              onTap:
                  () => {
                    provider.selectAsset(listAssets![index]),
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChooseAddressAndAmount(
                              selectedAsset: listAssets![index],
                              selectedNft: null,
                              isNftSelected: false,
                            ),
                      ),
                    ),
                  },
              child: AssetSelector(asset: listAssets![index]),
            ),
          ),
    );
  }
}
