import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:digital_asset_flutter/features/auth/presentation/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/source/network/user_datasources.dart';
import '../domain/usecases/user_usecase.dart';
import '../domain/entities/user.dart' as user_model;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  late final UserRepositoryImpl repo;
  late final UserUsecases userUsecase;

  @override
  void initState() {
    super.initState();
    repo = UserRepositoryImpl(http.Client());
    userUsecase = UserUsecases(userRepository: repo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2E), // Dark navy background
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and title
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35), // Orange color
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'B',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'BLC Wallet',
                            style: TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Spacer to center content
                      const Expanded(child: SizedBox()),

                      // Main content
                      Column(
                        children: [
                          // Login title
                          const Text(
                            'Log in to BLC Wallet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // Google login button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                Result<user_model.User> user =
                                    await userUsecase.login();
                                if (user.isSuccess) {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(content: Text('Welcome ${user.email}')),
                                  // );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              HomePage(user: user.data!),
                                    ),
                                    // MaterialPageRoute(
                                    //   builder:
                                    //       (context) =>
                                    //           UsernameScreen(user: user),
                                    // ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(user.error!.toString()),
                                    ),
                                  );
                                }
                              },
                              icon: Image.network(
                                'https://developers.google.com/identity/images/g-logo.png',
                                width: 20,
                                height: 20,
                              ),
                              label: const Text(
                                'Log in with Google',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF3A3B4A),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign up text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have a BLC Wallet account? ",
                                style: TextStyle(
                                  color: Color(0xFF8B8B8B),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  Result<user_model.User> user =
                                      await userUsecase.register();

                                  if (user.isSuccess) {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(content: Text('Welcome ${user.email}')),
                                    // );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                HomePage(user: user.data!),
                                      ),
                                      // MaterialPageRoute(
                                      //   builder:
                                      //       (context) =>
                                      //           UsernameScreen(user: user),
                                      // ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(user.error!.toString()),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B35),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Bottom spacer
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
      ),
    );
  }
}
