import 'package:flutter/material.dart';

class SecurityLevel extends StatelessWidget {
  const SecurityLevel({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.security, color: Colors.black, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                'Security Level: 2 of 9',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Text(
                'Boost security',
                style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // Security Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: LinearProgressIndicator(
            value: 2 / 9,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 4,
          ),
        ),

        const SizedBox(height: 20),

        // FaceLock Warning
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Add 3D FaceLock to protect your account',
                  style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
