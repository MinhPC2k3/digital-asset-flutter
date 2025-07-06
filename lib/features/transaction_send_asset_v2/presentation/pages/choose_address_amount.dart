import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/pages/transaction_review.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/provider/homepage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../user_v2/domain/entities/asset.dart';
import '../components/address_input.dart';
import '../components/amount_input.dart';
import '../components/selected_asset_info.dart';
import '../providers/transaction_send_asset_provider.dart';

class ChooseAddressAndAmount extends StatelessWidget {
  final Asset? selectedAsset;
  final NFT? selectedNft;
  final bool isNftSelected;

  const ChooseAddressAndAmount({
    super.key,
    required this.selectedAsset,
    required this.selectedNft,
    required this.isNftSelected,
  });

  void _navigateToReview(BuildContext context, String amount, String receiverAddress) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TransactionReviewScreen(
              amount: amount,
              receiverAddress: receiverAddress,
              nftItem: selectedNft,
              asset: selectedAsset,
            ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<HomepageProvider>(context, listen: true);
    return Consumer<TransactionSendAssetProvider>(
      builder: (context, transactionSendAssetProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF2A2A2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2A2A2A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                const Text('Send', style: TextStyle(color: Colors.white, fontSize: 18)),
                Text(
                  userProvider.currentWallet.walletName,
                  style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
                ),
              ],
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectedAssetInfo(
                  selectedAsset: selectedAsset,
                  selectedNft: selectedNft,
                  isSelectedNft: isNftSelected,
                ),
                const SizedBox(height: 24),
                const AddressInput(),
                const SizedBox(height: 24),
                const AmountInput(),
                const SizedBox(height: 40),
                Consumer<TransactionSendAssetProvider>(
                  builder:
                      (context, provider, _) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              provider.canProceed
                                  ? () {
                                    _navigateToReview(
                                      context,
                                      transactionSendAssetProvider.amountController.text,
                                      transactionSendAssetProvider.addressController.text,
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            disabledBackgroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
