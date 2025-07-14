import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInput extends StatefulWidget {
  final TextEditingController amountController;
  final String selectedSendToken;
  final String selectedReceiveToken;
  final double receiveAmount;
  final String? validationError;
  final double availableBalance;
  final bool isSmallScreen;
  final VoidCallback onMinimumPressed;
  final VoidCallback onMaximumPressed;

  const AmountInput({
    Key? key,
    required this.amountController,
    required this.selectedSendToken,
    required this.selectedReceiveToken,
    required this.receiveAmount,
    required this.validationError,
    required this.availableBalance,
    required this.isSmallScreen,
    required this.onMinimumPressed,
    required this.onMaximumPressed,
  }) : super(key: key);

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.isSmallScreen ? 16 : 20),
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
                  'Available: ${widget.availableBalance.toStringAsFixed(6)} ${widget.selectedSendToken}',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: widget.isSmallScreen ? 12 : 14,
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
              border: widget.validationError != null ? Border.all(color: Colors.red, width: 1) : null,
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: widget.amountController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true),
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
                                widget.selectedSendToken,
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // const Divider(),
                          // Text(
                          //   widget.receiveAmount > 0
                          //       ? '${widget.receiveAmount.toStringAsFixed(6)} ${widget.selectedReceiveToken}'
                          //       : '0 ${widget.selectedReceiveToken}',
                          //   style: TextStyle(
                          //     color: widget.receiveAmount > 0
                          //         ? const Color(0xFF10B981)
                          //         : const Color(0xFF9CA3AF),
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.validationError != null) ...[
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
                      widget.validationError!,
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
                  onPressed: widget.onMinimumPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3B45),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: widget.isSmallScreen ? 10 : 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Minimum', style: TextStyle(fontSize: widget.isSmallScreen ? 13 : 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onMaximumPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3B45),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: widget.isSmallScreen ? 10 : 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Maximum', style: TextStyle(fontSize: widget.isSmallScreen ? 13 : 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 