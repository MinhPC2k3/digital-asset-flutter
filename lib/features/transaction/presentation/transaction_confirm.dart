import 'package:digital_asset_flutter/core/constants/route.dart';
import 'package:digital_asset_flutter/features/transaction/domain/entities/transaction.dart'
    as transaction_model;
import 'package:digital_asset_flutter/features/wallet/data/network/wallet_datasources.dart';
import 'package:digital_asset_flutter/features/wallet/domain/usecases/wallet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../wallet/domain/entities/wallet.dart';
import '../domain/entities/transaction.dart';
import '../domain/usecases/transaction_usecases.dart';

class PinKeyboardModal extends StatefulWidget {
  final TransactionUsecase transactionUsecase;
  final transaction_model.Transaction transaction;
  final SignInfo signInfo;

  const PinKeyboardModal({
    super.key,
    required this.transactionUsecase,
    required this.signInfo,
    required this.transaction,
  });

  @override
  State<PinKeyboardModal> createState() => _PinKeyboardModalState();
}

class _PinKeyboardModalState extends State<PinKeyboardModal> {
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

    await widget.transactionUsecase.sendAsset(
      widget.transaction,
      widget.signInfo,
      _pinController.text,
    );
    var _walletRepo = WalletRepositoryImpl(http.Client());
    var _walletUsecase = WalletUsecases(walletRepository: _walletRepo);
    await _walletUsecase.getWalletAssetBalances(
      Provider.of<WalletProvider>(context, listen: false).wallet!,
    );
    setState(() {
      isLoading = false;
    });

    // Handle PIN verification result
    if (mounted) {
      CustomRouter.navigateTo(context, Routes.home); // Return success
    }
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
