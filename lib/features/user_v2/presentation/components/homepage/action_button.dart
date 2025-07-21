import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/pages/choose_asset.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/pages/choose_asset_and_amount.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/providers/swap_provider.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/provider/homepage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              // _buildActionButton(context, Icons.arrow_downward, 'Receive'),
              _buildActionButton(
                context,
                Icons.swap_horiz,
                'Swap',
                onTap: () => _showSwapScreen(context),
              ),
              // _buildActionButton(context, Icons.add, 'Buy'),
              // _buildActionButton(context, Icons.menu, 'More'),
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
  var listWallets = Provider.of<HomepageProvider>(context, listen: false).getWallets;
  if (listWallets.length < 2) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("You have to create other wallet first")));
    return;
  }

  var swapProvider = Provider.of<SwapProvider>(context, listen: false);
  swapProvider.currentWallet = Provider.of<HomepageProvider>(context, listen: false).currentWallet;
  swapProvider.userWallets = Provider.of<HomepageProvider>(context, listen: false).getWallets;

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SimpleSwapInterface(), fullscreenDialog: true),
  );
}
