import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route.dart';
import '../providers/pin_keyboard_provider.dart';
import 'pin_dots_display.dart';
import 'pin_input_field.dart';
import 'pin_action_buttons.dart';

class PinKeyboardModal extends StatefulWidget {
  final SignInfo signInfo;
  final Transaction transaction;

  const PinKeyboardModal({
    super.key,
    required this.signInfo,
    required this.transaction,
  });

  @override
  State<PinKeyboardModal> createState() => _PinKeyboardModalState();
}

class _PinKeyboardModalState extends State<PinKeyboardModal> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus to show keyboard immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PinKeyboardProvider(
        signInfo: widget.signInfo,
        transaction: widget.transaction,
      ),
      child: Container(
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
              child: Consumer<PinKeyboardProvider>(
                builder: (context, provider, _) => Column(
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
                    PinDotsDisplay(
                      pinLength: provider.pinLength,
                      filledDots: provider.pinController.text.length,
                    ),

                    const SizedBox(height: 40),

                    // Hidden text field for keyboard input
                    PinInputField(
                      controller: provider.pinController,
                      focusNode: _focusNode,
                      maxLength: provider.pinLength,
                    ),

                    // Loading or input area
                    if (provider.isLoading) ...[
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
                    if (!provider.isLoading)
                      PinActionButtons(
                        onCancel: () => Navigator.pop(context, false),
                        onConfirm: () async {
                          _focusNode.unfocus();
                          final success = await provider.submitPin(context);
                          if (success && mounted) {
                            CustomRouter.navigateTo(context, Routes.home);
                          }
                        },
                        isConfirmEnabled: provider.isPinComplete,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
