import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/components/transaction_confirm.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/providers/transaction_send_asset_provider.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/provider/user_provider.dart';
import '../../../user_v2/presentation/provider/homepage_provider.dart';
import '../components/action_buttons.dart';
import '../components/network_section.dart';
import '../components/transaction_amount_section.dart';
import '../components/transaction_details_section.dart';

class TransactionReviewScreen extends StatelessWidget {
  final String amount;
  final String receiverAddress;
  final Asset? asset;
  final NFT? nftItem;

  const TransactionReviewScreen({
    super.key,
    required this.amount,
    required this.receiverAddress,
    required this.asset,
    required this.nftItem,
  });

  void _showPinBottomModal(BuildContext context, Transaction transaction, SignInfo signInfo) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PinKeyboardModal(signInfo: signInfo, transaction: transaction),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.orange, size: 24),
        ),
        title: Column(
          children: [
            Text(
              'Review',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              // homepageProvider.currentWallet.walletName,
              'Mail wallet',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<TransactionSendAssetProvider>(
            builder:
                (context, provider, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    asset != null
                        ? TransactionAmountSection(amount: amount, symbol: asset!.symbol)
                        : TransactionAmountSection(
                          amount: nftItem!.name,
                          symbol: nftItem!.collection,
                        ),
                    const SizedBox(height: 20),
                    TransactionDetailsSection(
                      receiverAddress: receiverAddress,
                      networkFeeInFiat: provider.getNetworkFeeInFiat(),
                      networkFeeInAsset: provider.getNetworkFeeInAsset(),
                    ),
                    const SizedBox(height: 20),
                    const NetworkSection(),
                    const SizedBox(height: 20),
                    ActionButtons(
                      onCancel: () => Navigator.pop(context),
                      onSend: () async {
                        final result = await provider.prepareSendAssetTransaction(
                          userProvider.user!.id,
                          homepageProvider.currentWallet.walletId,
                          homepageProvider.currentWallet.networkName,
                          asset,
                          nftItem,
                          amount,
                          receiverAddress,
                        );

                        if (!result.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error when create transaction: ${result.error!.message}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (!context.mounted) return;
                        _showPinBottomModal(context, provider.createdTransaction, result.data!);
                      },
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
