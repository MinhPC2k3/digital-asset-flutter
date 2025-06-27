import 'dart:async';
import 'dart:convert';

import 'package:digital_asset_flutter/features/auth/data/source/network/user_datasources.dart';
import 'package:digital_asset_flutter/features/auth/domain/entities/user.dart';
import 'package:digital_asset_flutter/features/auth/domain/usecases/user_usecase.dart';
import 'package:digital_asset_flutter/features/wallet/presentation/create_wallet.dart';
import 'package:digital_asset_flutter/features/wallet/data/network/wallet_datasources.dart';
import 'package:digital_asset_flutter/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:provider/provider.dart';

import '../../../core/network/result.dart';
import '../../wallet/domain/entities/wallet.dart';
import '../../wallet/presentation/swap.dart';
import '../../wallet/presentation/wallet_selector.dart';
import '../../transaction/presentation/transaction_review.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({super.key}) {
    repo = UserRepositoryImpl(http.Client());
    userUsecase = UserUsecases(userRepository: repo);
    walletRepo = WalletRepositoryImpl(http.Client());
    walletUsecase = WallerUsecases(walletRepository: walletRepo);
  }

  late final UserRepositoryImpl repo;
  late final UserUsecases userUsecase;
  late final WalletRepositoryImpl walletRepo;
  late final WallerUsecases walletUsecase;

  void _showWalletSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WalletSelectorModal(walletUsecases: walletUsecase),
    );
  }

  void _showSendScreen(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final wallets = await walletUsecase.getUserWallet(userProvider.user!.id);
    if (!wallets.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(wallets.error!.toString())));
      return;
    }
    if (wallets.data!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You have to create wallet first")));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SendCryptoModal(),
    );
  }

  void _showSwapScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SwapScreen(), fullscreenDialog: true),
    );
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

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.orange : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.orange : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<WalletProvider>(context, listen: false).updateValuation(widget.walletUsecase);
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Essentials',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          // Make Main Wallet clickable
                          GestureDetector(
                            onTap: () async {
                              widget._showWalletSelector(context);
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Main Wallet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.keyboard_arrow_down, color: Colors.white),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.qr_code_scanner, color: Colors.orange, size: 20),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.logout, color: Colors.orange, size: 20),
                                ),
                                onTap: () async {
                                  widget.userUsecase.signOut();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Security Level
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.security, color: Colors.black, size: 16),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Security Level: 2 of 9',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Boost security',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Security Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: LinearProgressIndicator(
                        value: 2 / 9,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        minHeight: 4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FaceLock Warning
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.brown.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Add 3D FaceLock to protect your account',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Balance Section with Background
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.orange.withOpacity(0.3),
                            Colors.brown.withOpacity(0.5),
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'My Balance',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '\$${assetBalancesListenChange[0].balance}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.visibility_off, color: Colors.white70, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          widget._buildActionButton(
                            context,
                            Icons.arrow_upward,
                            'Send',
                            onTap: () => widget._showSendScreen(context),
                          ),
                          widget._buildActionButton(context, Icons.arrow_downward, 'Receive'),
                          widget._buildActionButton(
                            context,
                            Icons.swap_horiz,
                            'Swap',
                            onTap: () => widget._showSwapScreen(context),
                          ),
                          widget._buildActionButton(context, Icons.add, 'Buy'),
                          widget._buildActionButton(context, Icons.menu, 'More'),
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
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.close, color: Colors.grey, size: 20),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Ethereum Card
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Ξ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Ethereum',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ethereum',
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      assetBalancesListenChange[0]
                                          .last24hChange
                                          .toStringAsFixed(2)
                                          .toString(),
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    assetBalancesListenChange[0].last24hChange > 0
                                        ? Icon(Icons.trending_up, color: Colors.green, size: 16)
                                        : Icon(Icons.trending_down, color: Colors.red, size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${assetBalancesListenChange[0].balance}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${weiToEth(assetBalancesNotListenChange[0].assetBalance).toStringAsFixed(6)} ETH',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            widget._buildBottomNavItem(Icons.home, 'Home', true),
            widget._buildBottomNavItem(Icons.history, 'History', false),
            widget._buildBottomNavItem(Icons.settings, 'Settings', false),
            widget._buildBottomNavItem(Icons.security, 'Security', false),
          ],
        ),
      ),
    );
  }
}

// Send Crypto Modal
class SendCryptoModal extends StatelessWidget {
  const SendCryptoModal({Key? key}) : super(key: key);

  void _showSendAmountScreen(BuildContext context, String receiverAddress) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendAmountScreen(receiverAddress: receiverAddress),
        fullscreenDialog: true,
      ),
    );
  }

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
                    const Text('Main Wallet', style: TextStyle(color: Colors.grey, fontSize: 14)),
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
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[400], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(),
                    // Add controller if needed
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      // Handle search input
                      print('Search query: $value');
                    },
                    onSubmitted: (value) {
                      // Handle when user presses enter
                      print('Search submitted: $value');
                      _showSendAmountScreen(context, value);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // All Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'All',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Ethereum Item - Make it clickable
          GestureDetector(
            onTap:
                () => _showSendAmountScreen(context, "0x2a6A36dEB1593dEb03b0cFd6d1fb2Cb20BC93E2C"),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Ethereum Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        'Ξ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ethereum',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('ETH', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${assetBalancesListenChange[0].balance}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weiToEth(assetBalancesNotListenChange[0].assetBalance).toStringAsFixed(6)} ETH',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.chevron_right, color: Colors.grey, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Send Amount Screen
class SendAmountScreen extends StatefulWidget {
  const SendAmountScreen({super.key, required this.receiverAddress});

  final String receiverAddress;

  @override
  State<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends State<SendAmountScreen> {
  String amount = '0';

  void _onNumberPressed(String number) {
    setState(() {
      if (amount == '0') {
        amount = number;
      } else {
        amount += number;
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        amount = '0';
      }
    });
  }

  void _onDotPressed() {
    setState(() {
      amount = '$amount.';
    });
  }

  void _onUseMaxPressed() {
    setState(() {
      amount =
          weiToEth(
            Provider.of<WalletProvider>(
              context,
              listen: false,
            ).wallet!.assetBalances![0].assetBalance,
          ).toString(); // Max available amount
    });
  }

  void _showReviewScreen(BuildContext context, String receiverAddress) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TransactionReviewScreen(amount: amount, receiverAddress: receiverAddress),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.orange, size: 22),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Main Wallet',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Refresh icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.refresh, color: Colors.orange, size: 18),
                  ),
                ],
              ),
            ),

            // const Spacer(),

            // Amount Display
            Column(
              children: [
                Text(
                  '${amount}ETH',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                // const Text(
                //   '0 ETH',
                //   style: TextStyle(color: Colors.grey, fontSize: 13),
                // ),
                // const SizedBox(height: 14),
                Text(
                  '${weiToEth(Provider.of<WalletProvider>(context,listen: false).wallet!.assetBalances![0].assetBalance).toStringAsFixed(6)} ETH',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Use Max Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              child: ElevatedButton(
                onPressed: _onUseMaxPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Use Max',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // const Spacer(),

            // Number Pad
            Container(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // Row 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberButton('1'),
                      _buildNumberButton('2'),
                      _buildNumberButton('3'),
                    ],
                  ),
                  // Row 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberButton('4'),
                      _buildNumberButton('5'),
                      _buildNumberButton('6'),
                    ],
                  ),
                  // Row 3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberButton('7'),
                      _buildNumberButton('8'),
                      _buildNumberButton('9'),
                    ],
                  ),
                  // Row 4
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildDotButton(), _buildNumberButton('0'), _buildBackspaceButton()],
                  ),
                ],
              ),
            ),

            // Continue Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(18),
              child: ElevatedButton(
                onPressed:
                    amount != '0' ? () => _showReviewScreen(context, widget.receiverAddress) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: amount != '0' ? Colors.orange : Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNumberPressed(number),
        child: Container(
          height: 30,
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _onBackspacePressed,
        child: Container(
          height: 30,
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(Icons.backspace_outlined, color: Colors.white, size: 20)),
        ),
      ),
    );
  }

  Widget _buildDotButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onDotPressed(),
        child: Container(
          height: 30,
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
