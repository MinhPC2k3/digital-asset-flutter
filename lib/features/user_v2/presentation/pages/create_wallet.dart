import 'package:digital_asset_flutter/core/constants/route.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/components/create_wallet/pin_input.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/provider/create_wallet_provider.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/provider/homepage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/provider/user_provider.dart';

class CreateWalletScreen extends StatelessWidget {
  const CreateWalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateWalletProvider(),
      child: const CreateWalletView(),
    );
  }
}

class CreateWalletView extends StatelessWidget {
  const CreateWalletView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateWalletProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
    return provider.isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
          backgroundColor: const Color(0xFF1E1E1E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1E1E),
            elevation: 0,
            title: const Text('Create New Wallet', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.amber),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: provider.walletNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter wallet name',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (_) => provider.notifyListeners(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Network',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNetworkOption(
                    context,
                    'Ethereum',
                    'ETH Network',
                    Icons.currency_exchange,
                    Colors.white,
                  ),
                  const SizedBox(height: 8),
                  _buildNetworkOption(
                    context,
                    'Binance',
                    'BNB Network',
                    Icons.currency_franc,
                    Colors.amber,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Security PIN (6 digits)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Enter a 6-digit PIN to secure your wallet',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  buildPinInput(
                    provider.pinController,
                    provider.pinFocusNode,
                    provider.pinFilledStatus,
                    provider.updatePinFilledStatus,
                  ),
                  const Text(
                    'Repeat pin',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  buildPinInput(
                    provider.confirmPinController,
                    provider.confirmPinFocusNode,
                    provider.confirmPinFilledStatus,
                    provider.updateConfirmPinFilledStatus,
                  ),
                  const SizedBox(height: 32),
                  if (provider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          provider.isFormValid
                              ? () async {
                                final success = await provider.createWallet(
                                  userProvider.user!.id,
                                  context,
                                );
                                if (success) {
                                  homepageProvider.createNewWallet(provider.createdWallet!);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Wallet created successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    Routes.home,
                                    ModalRoute.withName(Routes.auth),
                                  );
                                }
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        disabledBackgroundColor: Colors.amber.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Create Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildNetworkOption(
    BuildContext context,
    String name,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final provider = Provider.of<CreateWalletProvider>(context);
    final isSelected = provider.selectedNetwork == name;

    return GestureDetector(
      onTap: () => provider.setSelectedNetwork(name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  // Widget _buildPinInput(BuildContext context) {
  //   final provider = Provider.of<CreateWalletProvider>(context);
  //
  //   return Column(
  //     children: [
  //       // Hidden text field for actual input
  //       Opacity(
  //         opacity: 0,
  //         child: TextField(
  //           controller: provider.pinController,
  //           focusNode: provider.pinFocusNode,
  //           keyboardType: TextInputType.number,
  //           inputFormatters: [
  //             FilteringTextInputFormatter.digitsOnly,
  //             LengthLimitingTextInputFormatter(6),
  //           ],
  //           onChanged: (_) => provider.updatePinFilledStatus(),
  //         ),
  //       ),
  //       // PIN display dots
  //       GestureDetector(
  //         onTap: () => provider.pinFocusNode.requestFocus(),
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(vertical: 16),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF2A2A2A),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: List.generate(
  //               6,
  //               (index) => Container(
  //                 width: 16,
  //                 height: 16,
  //                 margin: const EdgeInsets.symmetric(horizontal: 12),
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   color:
  //                       provider.pinFilledStatus[index]
  //                           ? Colors.amber
  //                           : Colors.grey.withOpacity(0.3),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       const Text(
  //         'Enter a 6-digit PIN to secure your wallet',
  //         style: TextStyle(color: Colors.grey, fontSize: 14),
  //         textAlign: TextAlign.center,
  //       ),
  //     ],
  //   );
  // }
}
