import 'package:digital_asset_flutter/features/transaction/presentation/transaction_address.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../component/asset_type_selector.dart';
import '../../wallet/domain/entities/wallet.dart';
import '../../wallet/domain/usecases/wallet_usecase.dart';

// Send Crypto Modal
class SendCryptoModal extends StatelessWidget {
  const SendCryptoModal({Key? key}) : super(key: key);

  // void _showSendAmountScreen(BuildContext context, String receiverAddress) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => SendAmountScreen(receiverAddress: receiverAddress),
  //       fullscreenDialog: true,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final walletWithoutListenChange = Provider.of<WalletProvider>(context, listen: false).wallet;

    List<AssetBalance> assetBalancesNotListenChange =
        walletWithoutListenChange?.assetBalances == null ||
                walletWithoutListenChange!.assetBalances!.isEmpty
            ? [defaultAssetBalance()]
            : walletWithoutListenChange.assetBalances!;

    final walletWithListenChange = Provider.of<WalletProvider>(context, listen: true).wallet;

    List<AssetBalance> assetBalancesListenChange =
        walletWithListenChange?.assetBalances == null ||
                walletWithListenChange!.assetBalances!.isEmpty
            ? [defaultAssetBalance()]
            : walletWithListenChange.assetBalances!;
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
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.orange, size: 24),
                ),
                Column(
                  children: [
                    const Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Provider.of<WalletProvider>(context, listen: true).wallet!.walletName,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                // Empty container to balance the layout
                const SizedBox(width: 24),
              ],
            ),
          ),
          // Send Crypto Title and Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send crypto',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Transfer your funds to another crypto wallet or exchange. You\'ll need their address.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
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
                        itemCount: assetBalancesListenChange.length,
                        itemBuilder:
                            (context, index) =>
                                assetBalancesListenChange[index].assetType != "NFT"
                                    ? Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                      child: GestureDetector(
                                        onTap:
                                            () => {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => SendAddressScreen(
                                                        wallet:
                                                            Provider.of<WalletProvider>(
                                                              context,
                                                              listen: false,
                                                            ).wallet!,
                                                        assetId: index,
                                                        nftItem: null,
                                                      ),
                                                  fullscreenDialog: true,
                                                ),
                                              ),
                                            },
                                        child: TokenAssetSelector(
                                          assetName: assetBalancesNotListenChange[index].assetId,
                                          assetSymbol:
                                              assetBalancesNotListenChange[index].assetSymbol,
                                          assetBalance: weiToEth(
                                                assetBalancesNotListenChange[index].assetBalance,
                                              )
                                              .toStringAsFixed(6)
                                              .replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""),
                                          balance: assetBalancesListenChange[index].balance,
                                          assetIcon: Icon(Icons.attach_money),
                                        ),
                                      ),
                                    )
                                    : Container(),
                      ),
                      walletWithListenChange!.nftItems != null
                          ? ListView.builder(
                            itemCount: walletWithListenChange!.nftItems!.length,
                            itemBuilder:
                                (context, index) => Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: GestureDetector(
                                    onTap:
                                        () => {
                                          print(
                                            "NFT type ${walletWithListenChange.nftItems![index].symbol}",
                                          ),
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => SendAddressScreen(
                                                    wallet:
                                                        Provider.of<WalletProvider>(
                                                          context,
                                                          listen: false,
                                                        ).wallet!,
                                                    assetId: index,
                                                    nftItem:
                                                        walletWithListenChange.nftItems![index],
                                                  ),
                                              fullscreenDialog: true,
                                            ),
                                          ),
                                        },
                                    child: NftAssetSelector(
                                      nftItem: walletWithListenChange.nftItems![index],
                                    ),
                                  ),
                                ),
                          )
                          : Container(),
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
