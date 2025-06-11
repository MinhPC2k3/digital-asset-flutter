import 'package:digital_asset_flutter/models/user.dart';
import 'package:flutter/material.dart';

import 'google_signin.dart';

class UsernameScreen extends StatelessWidget {
  final User user; // nhận vào user từ ngoài
  final GoogleAuthService _authService = GoogleAuthService();

  UsernameScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'User email: ${user.email}', // dùng giá trị từ struct
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'User id: ${user.id}', // dùng giá trị từ struct
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _authService.signOut();
                Navigator.pop(context);
              },
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
