import 'dart:async';

import 'package:digital_asset_flutter/core/constants/route.dart';
import 'package:digital_asset_flutter/features/auth/presentation/provider/user_provider.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/domain/entities/quote.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/components/pin_keyboard_modal.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/components/swap_details_section.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/providers/swap_provider.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/asset.dart';
import 'package:digital_asset_flutter/features/user_v2/domain/entities/wallet.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/provider/homepage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwapReviewPage extends StatelessWidget {
  final Wallet fromWallet;
  final Wallet toWallet;
  final Asset fromAsset;
  final Asset toAsset;
  final String amount;

  const SwapReviewPage({
    Key? key,
    required this.fromWallet,
    required this.toWallet,
    required this.fromAsset,
    required this.toAsset,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SwapProvider(),
      child: SwapReviewContent(
        txQuote: TransactionQuote(
          id: '',
          fromAsset: fromAsset,
          toAsset: toAsset,
          fromWallet: fromWallet,
          toWallet: toWallet,
          amountSwap: amount,
          amountReceive: '',
          estimatedFee: '',
          rate: 0,
          status: '',
          expirationAt: DateTime.timestamp(),
          depositAddress: '',
        ),
      ),
    );
  }
}

class SwapReviewContent extends StatelessWidget {
  final TransactionQuote txQuote;

  const SwapReviewContent({Key? key, required this.txQuote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SwapProvider>(context);
    final TextStyle bigTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    final TextStyle normalTextStyle = TextStyle(fontSize: 14, color: Colors.white);
    final TextStyle smallTextStyle = TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7));

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    return FutureBuilder(
      future: provider.loadQuote(
        txQuote.fromWallet,
        txQuote.toWallet,
        txQuote.fromAsset,
        txQuote.toAsset,
        txQuote.amountSwap,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // While waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFF2A2A2A),
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D31),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Swap', style: bigTextStyle.copyWith(fontSize: 24)),
                              const SizedBox(height: 10),
                              SwapDetailsSection(
                                quote: snapshot.data!.data!,
                                bigTextStyle: bigTextStyle,
                                normalTextStyle: normalTextStyle,
                                smallTextStyle: smallTextStyle,
                              ),
                              const SizedBox(height: 20),
                              Text('Fees', style: bigTextStyle.copyWith(fontSize: 24)),
                              const SizedBox(height: 10),
                              _buildFeesSection(
                                snapshot.data!.data!.estimatedFee,
                                bigTextStyle,
                                normalTextStyle,
                              ),
                              const SizedBox(height: 10),
                              _buildInfoMessage(normalTextStyle),
                              const SizedBox(height: 20),
                              Text('Network', style: bigTextStyle.copyWith(fontSize: 24)),
                              const SizedBox(height: 10),
                              _buildNetworkSection(bigTextStyle, smallTextStyle),
                              const SizedBox(height: 10),
                              QuoteReadyWidget(
                                initialDuration: snapshot.data!.data!.expirationAt.difference(
                                  DateTime.now(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
                      child: _buildContinueButton(
                        context,
                        Transaction(
                          userId: Provider.of<UserProvider>(context, listen: false).user!.id,
                          walletId:
                              Provider.of<HomepageProvider>(
                                context,
                                listen: false,
                              ).currentWallet.walletId,
                          assetId: snapshot.data!.data!.fromAsset.assetId,
                          amount: snapshot.data!.data!.amountSwap,
                          receiverAddress: snapshot.data!.data!.depositAddress,
                          blockchainType: null,
                          networkName:
                              Provider.of<HomepageProvider>(
                                context,
                                listen: false,
                              ).currentWallet.networkName.toLowerCase(),
                          transactionType: null,
                          tokenId: '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Text('No data');
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFF5A623), size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Text(
            'Review',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildFeesSection(String fee, TextStyle bigTextStyle, TextStyle normalTextStyle) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2023),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Network', style: bigTextStyle),
              const SizedBox(width: 5),
              Icon(Icons.info_outline, color: const Color(0xFFF5A623), size: 18),
            ],
          ),
          Text(fee, style: normalTextStyle),
        ],
      ),
    );
  }

  Widget _buildInfoMessage(TextStyle normalTextStyle) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4B2E83),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Network fee is paid on top of amount swapped', style: normalTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSection(TextStyle bigTextStyle, TextStyle smallTextStyle) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2023),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estimated Time', style: bigTextStyle),
                  Text('5-30 minutes', style: smallTextStyle),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildCryptoLogo(),
              const SizedBox(width: 10),
              Text('Ethereum', style: bigTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: const Color(0xFF627EEA), shape: BoxShape.circle),
          child: const Icon(Icons.currency_exchange, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, Transaction transaction) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            builder: (context) => PinKeyboardModal(transaction: transaction),
          );

          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            CustomRouter.navigateTo(context, Routes.home);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class QuoteReadyWidget extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback? onTimerExpired;

  const QuoteReadyWidget({Key? key, required this.initialDuration, this.onTimerExpired})
    : super(key: key);

  @override
  State<QuoteReadyWidget> createState() => _QuoteReadyWidgetState();
}

class _QuoteReadyWidgetState extends State<QuoteReadyWidget> {
  late Duration remainingTime;
  Timer? _timer;
  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.initialDuration;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = Duration(seconds: remainingTime.inSeconds - 1);
        } else {
          isExpired = true;
          _timer?.cancel();
          widget.onTimerExpired?.call();
        }
      });
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3B3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isExpired ? Colors.red : const Color(0xFF10B981), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isExpired ? Colors.red : const Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpired ? 'Quote Expired' : 'Quote Ready',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isExpired ? 'Rate has expired' : 'Rate locked for ${_formatTime(remainingTime)}',
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
