import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'models/api.dart';
import 'models/user.dart' as user_model;

/// A service class to handle Google Sign-In
// and authentication using Firebase.
class GoogleAuthService {
  // FirebaseAuth instance to handle authentication.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn instance to handle Google Sign-In.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  /// Signs in the user with Google and returns the authenticated Firebase [User].
  ///
  /// Returns `null` if the sign-in process is canceled or fails.
  Future<String> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow.
      await _googleSignIn.signOut();
      await _auth.signOut();
      final googleUser = await _googleSignIn.signIn();

      // User canceled the sign-in.
      if (googleUser == null) return "";

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
      return googleAuth.accessToken!;
    } catch (e) {
      // Print the error and return null if an exception occurs.
      print("Sign-in error: $e");
      return '';
    }
  }

  /// Signs out the user from both Google and Firebase.
  Future<void> signOut() async {
    // Sign out from Google.
    await _googleSignIn.signOut();

    // Sign out from Firebase.
    await _auth.signOut();

    user_model.User.empty;
  }
}

Future<Result<user_model.User>> userLogin(String token) async {
  String url =
      'https://9428-210-245-49-42.ngrok-free.app/v1/auth/login-with-google';
  Map<String, String> headers = {"Content-type": "application/json"};
  final Map<String, String> body = {'id_token': token};
  String reqBody = jsonEncode(body);

  Response res = await post(Uri.parse(url), headers: headers, body: reqBody);

  if (res.statusCode == 200) {
    return Result.success(
      user_model.User.fromJson(jsonDecode(res.body) as Map<String, dynamic>),
    );
  } else {
    final json = jsonDecode(res.body);
    return Result.failure(
      ApiError(
        statusCode: res.statusCode,
        message: json['message'] ?? 'Lỗi không xác định',
      ),
    );
  }
}

Future<Result<user_model.User>> userSignup(String token) async {
  String url =
      'https://9428-210-245-49-42.ngrok-free.app/v1/auth/register-with-google';
  Map<String, String> headers = {"Content-type": "application/json"};
  final Map<String, String> body = {'id_token': token};
  String reqBody = jsonEncode(body);

  Response res = await post(Uri.parse(url), headers: headers, body: reqBody);
  if (res.statusCode == 200) {
    return Result.success(
      user_model.User.fromJson(jsonDecode(res.body) as Map<String, dynamic>),
    );
  } else {
    final json = jsonDecode(res.body);
    return Result.failure(
      ApiError(
        statusCode: res.statusCode,
        message: json['message'] ?? 'Lỗi không xác định',
      ),
    );
  }
}
