import 'dart:convert';

import 'package:digital_asset_flutter/core/constants/common.dart';
import 'package:digital_asset_flutter/core/network/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../entities/user.dart' as user_model;

class UserUsecases {
  UserUsecases({required UserRepository userRepository}) : _userRepository = userRepository;
  final UserRepository _userRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  Future<String> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow.
      await _googleSignIn.signOut();
      await _auth.signOut();
      final googleUser = await _googleSignIn.signIn();

      // User canceled the sign-in.
      if (googleUser == null) {
        return "";
      }

      // Retrieve the authentication details from the Google account.
      final googleAuth = await googleUser.authentication;

      // Create a new credential using the Google authentication details.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential.
      final userCredential = await _auth.signInWithCredential(credential);

      // Return the authenticated user.
      // Result<user_model.User> user = await _userRepository.userLogin(
      //   googleAuth.accessToken!,
      // );
      return googleAuth.accessToken!;
    } catch (e) {
      // Print the error and return null if an exception occurs.
      print("Sign-in error: $e");
      return "";
    }
  }

  /// Signs out the user from both Google and Firebase.
  Future<void> signOut() async {
    // Sign out from Google.
    await _googleSignIn.signOut();

    // Sign out from Firebase.
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(localStorageUserKey);

    user_model.User.empty();
  }

  Future<Result<user_model.User>> login(String tokenId) async {
    // String tokenId = await signInWithGoogle();
    // if (tokenId == "") {
    //   print("Error google here");
    //   return Result.failure(
    //     ApiError(statusCode: 400, message: "login with Google error"),
    //   );
    // }
    Result<user_model.User> user = await _userRepository.userLogin(tokenId);
    if (user.isSuccess) {
      final prefs = await SharedPreferences.getInstance();
      String encodedString = jsonEncode(user.data!.toJson());
      prefs.setString(localStorageUserKey, encodedString);
    }
    return user;
  }

  Future<user_model.User?> getAlreadyLogin() async {
    final prefs = await SharedPreferences.getInstance();
    var userString = prefs.getString(localStorageUserKey);
    print("From local storage: $userString");
    if (userString == null) {
      return null;
    }
    Map<String, dynamic> jsonData = jsonDecode(userString);
    return user_model.User.fromJson(jsonData);
  }

  Future<Result<user_model.User>> register() async {
    String tokenId = await signInWithGoogle();
    if (tokenId == "") {
      return Result.failure(ApiError(statusCode: 400, message: "login with Google error"));
    }
    Result<user_model.User> user = await _userRepository.userRegister(tokenId);
    return user;
  }
}
