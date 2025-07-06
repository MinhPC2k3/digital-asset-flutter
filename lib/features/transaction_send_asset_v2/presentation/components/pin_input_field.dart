import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLength;

  const PinInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0,
      width: 0,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: maxLength,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(counterText: '', border: InputBorder.none),
        style: const TextStyle(color: Colors.transparent),
      ),
    );
  }
} 