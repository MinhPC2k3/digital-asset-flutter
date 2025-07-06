import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:flutter/material.dart';

import '../components/asset_list_view.dart';
import '../components/asset_search_bar.dart';
import '../components/send_crypto_header.dart';

// Send Crypto Modal
class ChooseAsset extends StatelessWidget {
  final Wallet userWallet;

  const ChooseAsset({super.key, required this.userWallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SendAssetHeader(walletName: userWallet.walletName, onClose: () => Navigator.pop(context)),

          // Send Crypto Title and Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Send crypto',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Transfer your funds to another crypto wallet or exchange. You\'ll need their address.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          AssetSearchBar(),

          DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [Tab(text: "Tokens"), Tab(text: "NFTs")],
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    children: [
                      AssetListView(listAssets: userWallet.assets, isNFT: false, listNfts: null),
                      AssetListView(isNFT: true, listAssets: null, listNfts: userWallet.nfts),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
