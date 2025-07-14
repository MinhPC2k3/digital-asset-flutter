import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/pages/swap_review_page.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/provider/homepage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/amount_input.dart';
import '../components/token_selector.dart';
import '../components/wallet_selector.dart';
import '../providers/swap_provider.dart';

class SwapPage extends StatelessWidget {
  const SwapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwapPageContent();
  }
}

class SwapPageContent extends StatelessWidget {
  const SwapPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final horizontalPadding = screenWidth * 0.05;
    final maxWidth = screenWidth > 600 ? 600.0 : screenWidth;
    final List<Asset> listOwnedAsset =
        Provider.of<HomepageProvider>(context, listen: true).currentWallet.assets;
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    return FutureBuilder(
      future: swapProvider.getListAsset(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Consumer<SwapProvider>(builder: (context,swapProvider,child){
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: const Color(0xFF1A1B23),
                  appBar: AppBar(
                    backgroundColor: const Color(0xFF1A1B23),
                    title: const Text(
                      'Swap',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    elevation: 0,
                    centerTitle: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTokenSelectionSection(
                              context,
                              isSmallScreen,
                              listOwnedAsset,
                              snapshot.data!.data!,
                            ),
                            const SizedBox(height: 16),
                            WalletSelector(
                              selectedWalletName: swapProvider.selectedWalletName,
                              otherWallets: swapProvider.otherWallets,
                              onWalletChanged: (value) => swapProvider.updateSelectedWallet(value!),
                              isSmallScreen: isSmallScreen,
                              selectedWallet: swapProvider.receiveSelectedWallet,
                            ),
                            const SizedBox(height: 16),
                            AmountInput(
                              amountController: swapProvider.amountController,
                              selectedSendToken: swapProvider.sendAsset.symbol,
                              selectedReceiveToken: swapProvider.selectedReceiveToken,
                              receiveAmount: swapProvider.calculateReceiveAmount(
                                swapProvider.enteredAmount,
                              ),
                              validationError: swapProvider.validationError,
                              availableBalance: double.parse(swapProvider.sendAsset.balance),
                              isSmallScreen: isSmallScreen,
                              onMinimumPressed: swapProvider.setMinimumAmount,
                              onMaximumPressed: swapProvider.setMaximumAmount,
                            ),
                            const SizedBox(height: 20),
                            _buildSwapButton(context, swapProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (swapProvider.isLoading)
                  Opacity(
                    opacity: 0.6,
                    child: ModalBarrier(
                      dismissible: false,
                      color: Colors.black,
                    ),
                  ),
                if (swapProvider.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          });
        }
      },
    );
  }

  Widget _buildTokenSelectionSection(
    BuildContext context,
    bool isSmallScreen,
    List<Asset> listOwnedAsset,
    List<Asset> listAssets,
  ) {
    final swapProvider = Provider.of<SwapProvider>(context);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Tokens',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          isSmallScreen
              ? _buildVerticalTokenSelector(swapProvider, listAssets, listOwnedAsset)
              : _buildHorizontalTokenSelector(swapProvider, listAssets, listOwnedAsset),
        ],
      ),
    );
  }

  Widget _buildVerticalTokenSelector(
    SwapProvider provider,
    List<Asset> listAssets,
    List<Asset> ownedAssets,
  ) {
    print(
      "From view list asset length ${listAssets[0].symbol},${listAssets[0].assetName}, list owned ${ownedAssets[0].symbol}",
    );
    return Column(
      children: [
        TokenSelector(
          label: 'Send',
          selectedToken: ownedAssets[0].symbol,
          onChanged: (value) => provider.updateSendToken(value!, ownedAssets),
          listAssets: ownedAssets,
        ),
        const SizedBox(height: 16),
        Center(child: _buildSwapTokensButton(provider)),
        const SizedBox(height: 16),
        TokenSelector(
          label: 'Receive',
          selectedToken: provider.selectedReceiveToken,
          onChanged: (value) => provider.updateReceiveToken(value!, listAssets),
          listAssets: listAssets,
        ),
      ],
    );
  }

  Widget _buildHorizontalTokenSelector(
    SwapProvider provider,
    List<Asset> listAssets,
    List<Asset> ownedAssets,
  ) {
    return Row(
      children: [
        Expanded(
          child: TokenSelector(
            label: 'Send',
            selectedToken: ownedAssets[0].symbol,
            onChanged: (value) => provider.updateSendToken(value!, ownedAssets),
            listAssets: ownedAssets,
          ),
        ),
        const SizedBox(width: 16),
        _buildSwapTokensButton(provider),
        const SizedBox(width: 16),
        Expanded(
          child: TokenSelector(
            label: 'Receive',
            selectedToken: provider.selectedReceiveToken,
            onChanged: (value) => provider.updateReceiveToken(value!, listAssets),
            listAssets: listAssets,
          ),
        ),
      ],
    );
  }

  Widget _buildSwapTokensButton(SwapProvider provider) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3B45),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4A4B55), width: 1),
        ),
        child: const Icon(Icons.swap_vert, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSwapButton(BuildContext context, SwapProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            provider.canSwap
                ? () async {
                  double receiveAmount = provider.calculateReceiveAmount(provider.enteredAmount);
                  var txQuote = await provider.loadQuote(
                    provider.currentWallet!,
                    provider.receiveSelectedWallet,
                    provider.sendAsset,
                    provider.receiveAsset,
                    provider.enteredAmount.toString(),
                  );
                  if (!txQuote.isSuccess){
                    print("Doing123");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(txQuote.error!.message), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SwapReviewPage(
                        toWallet: provider.receiveSelectedWallet,
                        fromWallet: provider.currentWallet!,
                        fromAsset: provider.sendAsset,
                        toAsset: provider.receiveAsset,
                        amount: provider.enteredAmount.toString(),
                        txQuote: txQuote.data!,
                      ),
                    ),
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: provider.canSwap ? const Color(0xFF10B981) : const Color(0xFF3A3B45),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Swap Tokens',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
