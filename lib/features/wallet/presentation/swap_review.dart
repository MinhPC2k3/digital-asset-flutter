import 'dart:async';

import 'package:digital_asset_flutter/features/transaction/data/source/network/transaction_datasource.dart';
import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction/presentation/provider/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/constants/route.dart';
import '../../../core/helper/helper.dart';
import '../../asset/domain/entities/entities.dart';
import '../../auth/presentation/provider/user_provider.dart';
import '../../transaction/domain/usecases/transaction_usecases.dart';
import '../data/network/wallet_datasources.dart';
import '../domain/entities/wallet.dart';
import '../domain/usecases/wallet_usecase.dart';

class SwapReviewScreen extends StatefulWidget {
  Wallet fromWallet;
  Wallet toWallet;
  AssetInfo fromAsset;
  AssetInfo toAsset;
  String amount;

  SwapReviewScreen({
    super.key,
    required this.toWallet,
    required this.fromWallet,
    required this.fromAsset,
    required this.toAsset,
    required this.amount,
  });

  @override
  SwapReviewScreenState createState() => SwapReviewScreenState();
}

class SwapReviewScreenState extends State<SwapReviewScreen> {
  @override
  Widget build(BuildContext context) {
    // Define text styles based on requirements
    final TextStyle bigTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final TextStyle normalTextStyle = TextStyle(fontSize: 14, color: Colors.white);

    final TextStyle smallTextStyle = TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7));

    var provider = Provider.of<TransactionProvider>(context, listen: false);

    return FutureBuilder(
      future: provider.loadQuote(
        widget.fromWallet,
        widget.toWallet,
        widget.fromAsset,
        widget.toAsset,
        widget.amount,
      ),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // While waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          if (!snapshot.data!.isSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error when get quote ${snapshot.data!.error!.message}')),
              );
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
          }
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
                              _buildSwapDetails(
                                bigTextStyle,
                                normalTextStyle,
                                smallTextStyle,
                                snapshot.data!.data!,
                              ),
                              const SizedBox(height: 20),
                              Text('Fees', style: bigTextStyle.copyWith(fontSize: 24)),
                              const SizedBox(height: 10),
                              _buildFeesSection(
                                bigTextStyle,
                                normalTextStyle,
                                smallTextStyle,
                                snapshot.data!.data!.estimatedFee,
                              ),
                              const SizedBox(height: 10),
                              _buildInfoMessage(normalTextStyle),
                              const SizedBox(height: 20),
                              Text('Network', style: bigTextStyle.copyWith(fontSize: 24)),
                              const SizedBox(height: 10),
                              _buildNetworkSection(bigTextStyle, normalTextStyle, smallTextStyle),
                              const SizedBox(height: 10),
                              QuoteReadyWidget(
                                initialDuration: snapshot.data!.data!.expirationTimestamp!
                                    .difference(DateTime.now()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
                      child: _buildSlideToConfirm(context, snapshot.data!.data!.depositAddress),
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const Text(
            'Review',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 40), // Balance the header
        ],
      ),
    );
  }

  Widget _buildSwapDetails(
    TextStyle bigTextStyle,
    TextStyle normalTextStyle,
    TextStyle smallTextStyle,
    TransactionSwap txSwap,
  ) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2023),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildCurrencyRow(
            'Send',
            txSwap.fromAsset!.assetSymbol,
            '${txSwap.fromAmount} ${txSwap.fromAsset!.assetSymbol}',
            'assets/ethereum_logo.png',
            smallTextStyle,
            bigTextStyle,
            normalTextStyle,
          ),
          const SizedBox(height: 20),
          _buildCurrencyRow(
            'Get',
            txSwap.toAsset!.assetSymbol,
            '${txSwap.toAmount} ${txSwap.toAsset!.assetSymbol}',
            'assets/bitcoin_logo.png',
            smallTextStyle,
            bigTextStyle,
            normalTextStyle,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Fixed Rate', style: bigTextStyle),
                  const SizedBox(width: 5),
                  Icon(Icons.info_outline, color: const Color(0xFFF5A623), size: 18),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('1 ${txSwap.fromAsset!.assetSymbol}', style: normalTextStyle),
                  Text('= ${txSwap.rate} ${txSwap.toAsset!.assetSymbol}', style: normalTextStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(
    String label,
    String currency,
    String amount,
    String logoPath,
    TextStyle smallTextStyle,
    TextStyle bigTextStyle,
    TextStyle normalTextStyle,
  ) {
    return Row(
      children: [
        _buildCryptoLogo(logoPath, currency),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(label, style: smallTextStyle), Text(currency, style: bigTextStyle)],
        ),
        const Spacer(),
        Text(amount, style: normalTextStyle),
      ],
    );
  }

  Widget _buildCryptoLogo(String path, String currency) {
    Color bgColor = currency == 'ETH' ? const Color(0xFF627EEA) : const Color(0xFFF7931A);

    IconData iconData = currency == 'ETH' ? Icons.currency_exchange : Icons.currency_bitcoin;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(iconData, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildFeesSection(
    TextStyle bigTextStyle,
    TextStyle normalTextStyle,
    TextStyle smallTextStyle,
    String fee,
  ) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Text(fee, style: normalTextStyle)],
          ),
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

  Widget _buildNetworkSection(
    TextStyle bigTextStyle,
    TextStyle normalTextStyle,
    TextStyle smallTextStyle,
  ) {
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
              _buildCryptoLogo('assets/ethereum_logo.png', 'ETH'),
              const SizedBox(width: 10),
              Text('Ethereum', style: bigTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlideToConfirm(BuildContext context, String depositAddress) {
    print("Deposit address ${depositAddress}");
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          var txRepo = TransactionRepositoryImpl(http.Client());
          var transactionUsecase = TransactionUsecase(transactionRepository: txRepo);
          var transaction = Transaction(
            userId: Provider.of<UserProvider>(context, listen: false).user!.id,
            walletId: Provider.of<WalletProvider>(context, listen: false).wallet!.id,
            assetId: widget.fromAsset.assetId,
            amount: widget.amount,
            receiverAddress: depositAddress,
            blockchainType: null,
            networkName: widget.fromAsset.networkName,
            transactionType: null,
            tokenId: '',
          );

          transaction = addTransactionType(transaction);
          var signResponse = await transactionUsecase.prepareSign(transaction);

          if (!signResponse.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error when create transaction: ${signResponse.error!.message}'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          _showPinBottomModal(context, transaction, signResponse.data!);

          // CustomRouter.navigateTo(context, Routes.home);
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

  void _showPinBottomModal(BuildContext context, Transaction transaction, SignInfo signInfo) async {
    var txRepo = TransactionRepositoryImpl(http.Client());
    var transactionUsecase = TransactionUsecase(transactionRepository: txRepo);
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder:
          (context) => SwapPinKeyboardModal(
            transactionUsecase: transactionUsecase,
            signInfo: signInfo,
            transaction: transaction,
          ),
    );

    if (result == true) {
      // PIN verified successfully, proceed with transaction
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class QuoteReadyWidget extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback? onTimerExpired;
  final String title;
  final String subtitle;

  const QuoteReadyWidget({
    super.key,
    required this.initialDuration,
    this.onTimerExpired,
    this.title = 'Quote Ready',
    this.subtitle = 'Rate locked for',
  });

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
          // Status indicator dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isExpired ? Colors.red : const Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpired ? 'Quote Expired' : widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isExpired
                      ? 'Rate has expired'
                      : '${widget.subtitle} ${_formatTime(remainingTime)}',
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

// Example usage widget
class QuoteReadyExample extends StatefulWidget {
  const QuoteReadyExample({Key? key}) : super(key: key);

  @override
  State<QuoteReadyExample> createState() => _QuoteReadyExampleState();
}

class _QuoteReadyExampleState extends State<QuoteReadyExample> {
  bool showQuote = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B23),
        title: const Text('Quote Timer Demo', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (showQuote)
            QuoteReadyWidget(
              initialDuration: const Duration(minutes: 4, seconds: 42),
              onTimerExpired: () {
                // Handle timer expiration
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quote has expired!'), backgroundColor: Colors.red),
                );
              },
            ),
          const SizedBox(height: 20),
          // Demo controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showQuote = false;
                    });
                    Future.delayed(const Duration(milliseconds: 100), () {
                      setState(() {
                        showQuote = true;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Reset Timer'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showQuote = false;
                    });
                    Future.delayed(const Duration(milliseconds: 100), () {
                      setState(() {
                        showQuote = true;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3B45),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Start New Quote'),
                ),
              ],
            ),
          ),
          // Different timer examples
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Different Timer Examples:',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          QuoteReadyWidget(
            initialDuration: const Duration(seconds: 30),
            title: 'Quick Quote',
            subtitle: 'Expires in',
            onTimerExpired: () {
              print('Quick quote expired');
            },
          ),
          QuoteReadyWidget(
            initialDuration: const Duration(minutes: 10),
            title: 'Extended Quote',
            subtitle: 'Valid for',
            onTimerExpired: () {
              print('Extended quote expired');
            },
          ),
        ],
      ),
    );
  }
}

// Custom countdown widget with more features
class AdvancedQuoteWidget extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback? onTimerExpired;
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool showProgressBar;

  const AdvancedQuoteWidget({
    Key? key,
    this.initialDuration = const Duration(minutes: 5),
    this.onTimerExpired,
    this.title = 'Quote Ready',
    this.subtitle = 'Rate locked for',
    this.accentColor = const Color(0xFF10B981),
    this.showProgressBar = false,
  }) : super(key: key);

  @override
  State<AdvancedQuoteWidget> createState() => _AdvancedQuoteWidgetState();
}

class _AdvancedQuoteWidgetState extends State<AdvancedQuoteWidget> with TickerProviderStateMixin {
  late Duration remainingTime;
  late Duration totalTime;
  Timer? _timer;
  bool isExpired = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.initialDuration;
    totalTime = widget.initialDuration;

    _pulseController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = Duration(seconds: remainingTime.inSeconds - 1);

          // Start pulsing when less than 30 seconds remain
          if (remainingTime.inSeconds <= 30 && remainingTime.inSeconds > 0) {
            _pulseController.repeat(reverse: true);
          }
        } else {
          isExpired = true;
          _timer?.cancel();
          _pulseController.stop();
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

  double get progress {
    if (totalTime.inSeconds == 0) return 0.0;
    return (totalTime.inSeconds - remainingTime.inSeconds) / totalTime.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    Color currentColor = isExpired ? Colors.red : widget.accentColor;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: remainingTime.inSeconds <= 30 && !isExpired ? _pulseAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A3B3A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: currentColor, width: 1.5),
              boxShadow:
                  remainingTime.inSeconds <= 30 && !isExpired
                      ? [
                        BoxShadow(
                          color: currentColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                      : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Status indicator dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpired ? 'Quote Expired' : widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isExpired
                                ? 'Rate has expired'
                                : '${widget.subtitle} ${_formatTime(remainingTime)}',
                            style: TextStyle(
                              color:
                                  remainingTime.inSeconds <= 30 && !isExpired
                                      ? Colors.orange
                                      : const Color(0xFF9CA3AF),
                              fontSize: 14,
                              fontWeight:
                                  remainingTime.inSeconds <= 30 && !isExpired
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.showProgressBar && !isExpired) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFF3A3B45),
                    valueColor: AlwaysStoppedAnimation<Color>(currentColor),
                    minHeight: 4,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class SwapPinKeyboardModal extends StatefulWidget {
  final TransactionUsecase transactionUsecase;
  final Transaction transaction;
  final SignInfo signInfo;

  const SwapPinKeyboardModal({
    super.key,
    required this.transactionUsecase,
    required this.signInfo,
    required this.transaction,
  });

  @override
  State<SwapPinKeyboardModal> createState() => _SwapPinKeyboardModalState();
}

class _SwapPinKeyboardModalState extends State<SwapPinKeyboardModal> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final int pinLength = 6;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus to show keyboard immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _pinController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitPin() async {
    // Hide keyboard
    _focusNode.unfocus();

    setState(() {
      isLoading = true;
    });

    var res = await widget.transactionUsecase.sendAsset(
      widget.transaction,
      widget.signInfo,
      _pinController.text,
    );
    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction sent asset successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      var _walletRepo = WalletRepositoryImpl(http.Client());
      var _walletUsecase = WalletUsecases(walletRepository: _walletRepo);
      await _walletUsecase.getWalletAssetBalances(
        Provider.of<WalletProvider>(context, listen: false).wallet!,
      );
      setState(() {
        isLoading = false;
      });
      print("Doing after success");

      // Handle PIN verification result
      if (mounted) {
        CustomRouter.navigateTo(context, Routes.home); // Return success
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction sent asset fail with error: ${res.error!.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF5A5A5A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              children: [
                // Header
                const Text(
                  'Enter PIN',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter your 6-digit PIN to confirm transaction',
                  style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // PIN dots display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pinLength, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            index < _pinController.text.length
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF3A3B4A),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Hidden text field for keyboard input
                Container(
                  height: 0,
                  width: 0,
                  child: TextField(
                    controller: _pinController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: pinLength,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                    style: const TextStyle(color: Colors.transparent),
                  ),
                ),

                // Loading or input area
                if (isLoading) ...[
                  const SizedBox(height: 60),
                  const CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  const SizedBox(height: 16),
                  const Text(
                    'Verifying PIN...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],

                const SizedBox(height: 32),

                // Action buttons
                if (!isLoading)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pinController.text.length == pinLength ? _submitPin : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            disabledBackgroundColor: const Color(0xFF3A3B4A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
