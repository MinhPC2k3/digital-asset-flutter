import 'package:flutter/material.dart';

Widget networkOption(
  String name,
  String subtitle,
  IconData icon,
  Color iconColor,
  bool isSelected,
) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.black26,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
        const Spacer(),
        if (isSelected) const Icon(Icons.check_circle, color: Colors.amber),
      ],
    ),
  );
}
