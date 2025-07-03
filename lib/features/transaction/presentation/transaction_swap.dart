import 'package:digital_asset_flutter/features/asset/domain/entities/entities.dart';
import 'package:digital_asset_flutter/features/auth/presentation/provider/user_provider.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/constants/route.dart';
import '../../../core/helper/helper.dart';
import '../../wallet/data/network/wallet_datasources.dart';
import '../../wallet/domain/usecases/wallet_usecase.dart';
import '../../wallet/presentation/swap_review.dart';
import '../domain/entities/transaction.dart';
import '../domain/usecases/transaction_usecases.dart';

class SimpleSwapInterface extends StatefulWidget {
  const SimpleSwapInterface({super.key, required this.userWallets, required this.currentWallet});

  final List<Wallet> userWallets;
  final Wallet currentWallet;

  @override
  State<SimpleSwapInterface> createState() => _SimpleSwapInterfaceState();
}

class _SimpleSwapInterfaceState extends State<SimpleSwapInterface> {
  String selectedSendToken = 'ETH';
  String selectedReceiveToken = 'BNB';
  String selectedReceiveNetwork = "Binance";
  TextEditingController amountController = TextEditingController();
  var selectedWalletName = "";
  late Wallet receiveSelectedWallet;
  late AssetInfo sendAsset;
  late AssetInfo receiveAsset;

  // Available balances for different tokens
  List<AssetBalance> availableBalances = [];

  // Exchange rates (simplified for demo - token to token conversion)
  final Map<String, double> exchangeRates = {
    'ETH': 2000.0,
    'BTC': 45000.0,
    'BNB': 300.0,
    'ADA': 0.5,
  };

  String? validationError;
  double enteredAmount = 0.0;

  List<Wallet> otherWallet = [];

  @override
  void initState() {
    super.initState();
    amountController.addListener(_onAmountChanged);
    for (int i = 0; i < widget.userWallets.length; i++) {
      if (widget.userWallets[i].id != widget.currentWallet.id) {
        otherWallet.add(widget.userWallets[i]);
      }
    }
    selectedWalletName =
        '${otherWallet[0].walletName} - ${otherWallet[0].networkName} - ${otherWallet[0].address}';
    receiveSelectedWallet = otherWallet[0];
  }

  @override
  void dispose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {
      String text = amountController.text;
      if (text.isEmpty) {
        enteredAmount = 0.0;
        validationError = null;
        return;
      }

      try {
        double amount = double.parse(text);
        enteredAmount = amount;
        validationError = _validateAmount(amount);
      } catch (e) {
        enteredAmount = 0.0;
        validationError = 'Invalid number format';
      }
    });
  }

  String? _validateAmount(double amount) {
    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    var selectedSendAsset = availableBalances.firstWhere((t) => t.assetSymbol == selectedSendToken);
    double availableBalance = convertWithDecimal(
      double.parse(selectedSendAsset.assetBalance),
      selectedSendAsset.decimals,
    );

    if (amount > availableBalance) {
      return 'Insufficient balance. Available: ${availableBalance.toStringAsFixed(6)} $selectedSendToken';
    }

    if (amount == 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  double _calculateReceiveAmount(double sendAmount) {
    double sendRate = exchangeRates[selectedSendToken] ?? 0.0;
    double receiveRate = exchangeRates[selectedReceiveToken] ?? 0.0;

    if (receiveRate == 0) return 0.0;

    double usdValue = sendAmount * sendRate;
    return usdValue / receiveRate;
  }

  void _setMaximumAmount() {
    var selectedSendAsset = availableBalances.firstWhere((t) => t.assetSymbol == selectedSendToken);
    double maxAmount = convertWithDecimal(
      double.parse(selectedSendAsset.assetBalance),
      selectedSendAsset.decimals,
    );
    amountController.text = maxAmount.toStringAsFixed(6);
  }

  void _setMinimumAmount() {
    // Set a reasonable minimum (0.001 for most tokens)
    amountController.text = '0.001';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final horizontalPadding = screenWidth * 0.05;
    final maxWidth = screenWidth > 600 ? 600.0 : screenWidth;
    final List<AssetInfo> listAssets = Provider.of<AssetProvider>(context).listAssetInfo;
    availableBalances = Provider.of<WalletProvider>(context, listen: false).wallet!.assetBalances!;
    sendAsset = listAssets.firstWhere((t) => t.assetSymbol == "ETH");
    receiveAsset = listAssets.firstWhere((t) => t.assetSymbol == "BNB");
    return Scaffold(
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
          icon: Icon(Icons.arrow_back, color: Colors.white), // Custom icon and color
          onPressed: () => Navigator.of(context).pop(), // Pop the route
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
                _buildChooseTokensSection(isSmallScreen, listAssets),
                const SizedBox(height: 16),
                _buildDestinationWalletSection(isSmallScreen, otherWallet),
                const SizedBox(height: 16),
                _buildChooseAmountSection(isSmallScreen),
                const SizedBox(height: 20),
                _buildSwapActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChooseTokensSection(bool isSmallScreen, List<AssetInfo> listAssets) {
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
              ? _buildVerticalTokenSelector(listAssets)
              : _buildHorizontalTokenSelector(listAssets),
        ],
      ),
    );
  }

  Widget _buildHorizontalTokenSelector(List<AssetInfo> assetInfos) {
    return Row(
      children: [
        Expanded(
          child: _buildTokenSelector(
            label: 'Send',
            selectedToken: selectedSendToken,
            onChanged: (value) {
              setState(() {
                selectedSendToken = value!;
                // Revalidate amount when token changes
                if (amountController.text.isNotEmpty) {
                  _onAmountChanged();
                }
                sendAsset = assetInfos.firstWhere((t) => t.assetSymbol == value);
              });
            },
            listAssets: assetInfos,
          ),
        ),
        const SizedBox(width: 16),
        _buildSwapButton(),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTokenSelector(
            label: 'Receive',
            selectedToken: selectedReceiveToken,
            onChanged:
                (value) => {
                  setState(() {
                    selectedReceiveToken = value!;
                    for (int i = 0; i < assetInfos.length; i++) {
                      if (assetInfos[i].assetSymbol == selectedReceiveToken) {
                        setState(() {
                          selectedReceiveNetwork = assetInfos[i].networkName;
                        });
                      }
                    }
                    receiveAsset = assetInfos.firstWhere((t) => t.assetSymbol == value);
                    // Recalculate receive amount when token changes
                    _onAmountChanged();
                  }),
                },
            listAssets: assetInfos,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalTokenSelector(List<AssetInfo> assetInfos) {
    return Column(
      children: [
        _buildTokenSelector(
          label: 'Send',
          selectedToken: selectedSendToken,
          onChanged: (value) {
            setState(() {
              selectedSendToken = value!;
              if (amountController.text.isNotEmpty) {
                _onAmountChanged();
              }
              sendAsset = assetInfos.firstWhere((t) => t.assetSymbol == value);
            });
          },
          listAssets: assetInfos,
        ),
        const SizedBox(height: 16),
        Center(child: _buildSwapButton()),
        const SizedBox(height: 16),
        _buildTokenSelector(
          label: 'Receive',
          selectedToken: selectedReceiveToken,
          onChanged: (value) {
            setState(() {
              selectedReceiveToken = value!;
              for (int i = 0; i < assetInfos.length; i++) {
                if (assetInfos[i].assetSymbol == selectedReceiveToken) {
                  setState(() {
                    selectedReceiveNetwork = assetInfos[i].networkName;
                  });
                }
              }
              receiveAsset = assetInfos.firstWhere((t) => t.assetSymbol == value);
              _onAmountChanged();
            });
          },
          listAssets: assetInfos,
        ),
      ],
    );
  }

  Widget _buildSwapButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          String temp = selectedSendToken;
          selectedSendToken = selectedReceiveToken;
          selectedReceiveToken = temp;
          // Revalidate after swap
          if (amountController.text.isNotEmpty) {
            _onAmountChanged();
          }
        });
      },
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

  Widget _buildTokenSelector({
    required String label,
    required String selectedToken,
    required ValueChanged<String?> onChanged,
    required List<AssetInfo> listAssets,
  }) {
    AssetInfo assets = listAssets.firstWhere((t) => t.assetSymbol == selectedToken);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3B45),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedToken,
              onChanged: onChanged,
              dropdownColor: const Color(0xFF3A3B45),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              isExpanded: true,
              items:
                  listAssets.map((AssetInfo asset) {
                    return DropdownMenuItem<String>(
                      value: asset.assetSymbol,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                asset.assetSymbol[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  asset.assetSymbol,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  asset.assetName,
                                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationWalletSection(bool isSmallScreen, List<Wallet> otherWallet) {
    Wallet wallet = otherWallet.firstWhere(
      (w) => '${w.walletName} - ${w.networkName} - ${w.address}' == selectedWalletName,
    );
    receiveSelectedWallet = wallet;
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
            'Destination Wallet',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a wallet compatible with $selectedReceiveNetwork network to receive $selectedReceiveToken',
            style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: isSmallScreen ? 13 : 14),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3B45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedWalletName,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedWalletName = newValue!;
                        });
                      },
                      dropdownColor: const Color(0xFF3A3B45),
                      icon: const SizedBox.shrink(),
                      isExpanded: true,
                      items:
                          otherWallet.map<DropdownMenuItem<String>>((Wallet wallet) {
                            return DropdownMenuItem<String>(
                              value:
                                  '${wallet.walletName} - ${wallet.networkName} - ${wallet.address}',
                              child: Text(
                                '${wallet.walletName} - ${wallet.networkName} - ${wallet.address}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: wallet.address));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address copied to clipboard'),
                        backgroundColor: Color(0xFF10B981),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4B55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.copy, color: Color(0xFF9CA3AF), size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            children: [
              Text(
                'Selected: ',
                style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: isSmallScreen ? 11 : 12),
              ),
              Text(
                wallet.walletName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3B45),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${wallet.networkName.toUpperCase()} Network',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: isSmallScreen ? 9 : 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChooseAmountSection(bool isSmallScreen) {
    // var selectedSendAsset = availableBalances.firstWhere(
    //   (t) => t.assetSymbol == selectedSendToken,
    //   orElse: () => null,
    // );
    AssetBalance? selectedSendAsset;
    for (int i = 0; i < availableBalances.length; i++) {
      if (availableBalances[i].assetSymbol == selectedSendToken) {
        selectedSendAsset = availableBalances[i];
      }
    }
    if (selectedSendAsset == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Balance not enough to swap")));
      });

      return Container();
    }
    double availableBalance = convertWithDecimal(
      double.parse(selectedSendAsset.assetBalance),
      selectedSendAsset.decimals,
    );
    print("From swap ${selectedSendAsset.assetBalance}, ${selectedSendAsset.decimals}");
    double receiveAmount = _calculateReceiveAmount(enteredAmount);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Amount',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  'Available: ${availableBalance.toStringAsFixed(6)} $selectedSendToken',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3B45),
              borderRadius: BorderRadius.circular(8),
              border: validationError != null ? Border.all(color: Colors.red, width: 1) : null,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input amount with token
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: amountController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              Text(
                                selectedSendToken,
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          // Receive amount
                          Text(
                            receiveAmount > 0
                                ? '${receiveAmount.toStringAsFixed(6)} $selectedReceiveToken'
                                : '0 $selectedReceiveToken',
                            style: TextStyle(
                              color:
                                  receiveAmount > 0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF9CA3AF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (validationError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      validationError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _setMinimumAmount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3B45),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Minimum', style: TextStyle(fontSize: isSmallScreen ? 13 : 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _setMaximumAmount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3B45),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Maximum', style: TextStyle(fontSize: isSmallScreen ? 13 : 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwapActionButton() {
    bool canSwap = validationError == null && enteredAmount > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            canSwap
                ? () {
                  double receiveAmount = _calculateReceiveAmount(enteredAmount);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SwapReviewScreen(
                            toWallet: receiveSelectedWallet,
                            fromWallet: widget.currentWallet,
                            fromAsset: sendAsset,
                            toAsset: receiveAsset,
                            amount: enteredAmount.toString(),
                          ),
                    ),
                  );
                }
                : () => {},
        style: ElevatedButton.styleFrom(
          backgroundColor: canSwap ? const Color(0xFF10B981) : const Color(0xFF3A3B45),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          'Swap Tokens',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
