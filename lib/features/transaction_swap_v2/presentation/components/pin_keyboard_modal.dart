import 'package:digital_asset_flutter/features/transaction_send_asset_v2/domain/entities/transaction.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/providers/swap_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PinKeyboardModal extends StatefulWidget {
  final Transaction transaction;

  const PinKeyboardModal({Key? key, required this.transaction}) : super(key: key);

  @override
  State<PinKeyboardModal> createState() => _PinKeyboardModalState();
}

class _PinKeyboardModalState extends State<PinKeyboardModal> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final int pinLength = 6;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SwapProvider>(context, listen: false);
    var isLoading = Provider.of<SwapProvider>(context, listen: true).isLoading;
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
                SizedBox(
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
                          onPressed:
                              _pinController.text.length == pinLength
                                  ? () {
                                    provider.submitTransaction(
                                      _pinController.text,
                                      widget.transaction,
                                      context,
                                    );
                                    _pinController.clear();
                                  }
                                  : null,
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
