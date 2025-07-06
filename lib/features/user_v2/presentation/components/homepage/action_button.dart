import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/pages/choose_asset.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/provider/homepage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../transaction/presentation/transaction_swap.dart';
import '../../../../wallet/domain/entities/wallet.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                Icons.arrow_upward,
                'Send',
                onTap: () => _showSendScreen(context),
              ),
              _buildActionButton(context, Icons.arrow_downward, 'Receive'),
              _buildActionButton(
                context,
                Icons.swap_horiz,
                'Swap',
                onTap: () => _showSwapScreen(context),
              ),
              _buildActionButton(context, Icons.add, 'Buy'),
              _buildActionButton(context, Icons.menu, 'More'),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Zengo Pro Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.credit_card, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buy crypto with up to 50% less fees\nwith Zengo Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Try Pro Now',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 12),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.close, color: Colors.grey, size: 20)),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildActionButton(
  BuildContext context,
  IconData icon,
  String label, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

void _showSendScreen(BuildContext context) async {
  final homepage = Provider.of<HomepageProvider>(context, listen: false);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ChooseAsset(userWallet: homepage.currentWallet),
  );
}

void _showSwapScreen(BuildContext context) {
  var listWallets = Provider.of<WalletProvider>(context, listen: false).listWallet;
  if (listWallets.length < 2) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("You have to create other wallet first")));
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => SimpleSwapInterface(
            userWallets: listWallets,
            currentWallet: Provider.of<WalletProvider>(context).wallet!,
          ),
      fullscreenDialog: true,
    ),
  );
}
