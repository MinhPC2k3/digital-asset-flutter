import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildPinInput(
    TextEditingController textController,
    FocusNode focusNode,
    List<bool> isFilled,
    void Function() updateFunction,
    ) {
  return Stack(
    children: [
      // Hidden text field for actual input
      Positioned(
        left: -999,
        top: 0,
        child: SizedBox(
          width: 1,
          height: 1,
          child: TextField(
            controller: textController,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (value) {
              updateFunction();
            },
          ),
        ),
      ),
      // PIN display dots
      GestureDetector(
        onTap: () => focusNode.requestFocus(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              6,
                  (index) => Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled[index] ? Colors.amber : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}