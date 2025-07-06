import 'package:flutter/material.dart';

class PinDotsDisplay extends StatelessWidget {
  final int pinLength;
  final int filledDots;

  const PinDotsDisplay({
    super.key,
    required this.pinLength,
    required this.filledDots,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < filledDots
                ? const Color(0xFFFF6B35)
                : const Color(0xFF3A3B4A),
          ),
        );
      }),
    );
  }
} 