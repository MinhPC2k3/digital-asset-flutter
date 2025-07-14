import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../component/asset_card.dart';
import '../../provider/homepage_provider.dart';

class AssetDisplay extends StatelessWidget {
  const AssetDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomepageProvider>(
      builder: (context, homepageProvider, child) {
        return Column(
          children: [
            DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    tabs: [Tab(text: "Tokens"), Tab(text: "NFTs")],
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          itemCount: homepageProvider.currentWallet.assets.length,
                          itemBuilder: (context, index) {
                            return AssetCard(
                              assetSymbol: homepageProvider.currentWallet.assets[index].symbol,
                              balance: homepageProvider.currentWallet.assets[index].valuationUsd
                                  .toStringAsFixed(2),
                              assetBalance: double.parse(
                                homepageProvider.currentWallet.assets[index].balance,
                              ),
                              lastChange:
                                  homepageProvider.currentWallet.assets[index].last24hChange,
                            );
                          },
                        ),
                        homepageProvider.currentWallet.nfts != null
                            ? ListView.builder(
                              itemCount: homepageProvider.currentWallet.nfts!.length,
                              // physics: NeverScrollableScrollPhysics(), // disable inner scrolling
                              // shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return NftCard(
                                  nftName: homepageProvider.currentWallet.nfts![index].name,
                                  type: 'NFT',
                                  id: homepageProvider.currentWallet.nfts![index].tokenId,
                                  nftType: homepageProvider.currentWallet.nfts![index].collection,
                                  // assetSymbol:provider.getNftItem()![index].name,
                                  // balance: provider.getNftItem()![index].symbol,
                                  // assetBalance: 0,
                                  // lastChange:
                                  //     0,
                                );
                              },
                            )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
