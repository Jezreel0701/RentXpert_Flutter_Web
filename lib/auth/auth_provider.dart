import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../config/config.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final FlutterSecureStorage _storage;

  AuthService()
      : _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _messaging = FirebaseMessaging.instance,
        _storage = const FlutterSecureStorage();

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Handle successful authentication
  Future<Map<String, dynamic>> _handleSuccessfulAuth(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) throw Exception("User is null after authentication");

    // Get Firebase ID token
    final idToken = await user.getIdToken();
    if (idToken == null) throw Exception("Failed to get ID token");

    // Send token to backend and get JWT
    final backendSuccess = await sendTokenToBackend(idToken);
    if (!backendSuccess) throw Exception("Failed to authenticate with backend");

    // Setup push notifications
    await _setupPushNotifications(user.uid);

    // Get user data from secure storage
    final jwtToken = await _storage.read(key: "jwt_token");
    final email = await _storage.read(key: "email");

    return {
      'success': true,
      'token': jwtToken,
      'email': email,
      'userId': user.uid,
    };
  }

  // Email/Password Login
  Future<Map<String, dynamic>> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _handleSuccessfulAuth(userCredential);
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getFirebaseAuthErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Helper to get user-friendly error messages
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Login failed. Please try again';
    }
  }

  // Send Firebase token to backend
  Future<bool> sendTokenToBackend(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/firebase/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_token": idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: "jwt_token", value: data["access_token"]);
        await _storage.write(key: "email", value: data["email"]);
        return true;
      } else {
        debugPrint("Backend authentication failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Error sending token to backend: $e");
      return false;
    }
  }

  // Push notification setup
  // Push notification setup
  Future<void> _setupPushNotifications(String userId) async {
    try {
      await _messaging.deleteToken(); // Optional: force refresh

      final settings = await _messaging.requestPermission(
        alert: true, badge: true, sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fcmToken = await _messaging.getToken();

        if (fcmToken != null) {
          debugPrint('📲 Generated FCM Token: $fcmToken'); // <-- print here

          await _firestore.collection('user_tokens').doc(userId).set({
            'tokens': FieldValue.arrayUnion([fcmToken]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        _messaging.onTokenRefresh.listen((newToken) async {
          debugPrint('🔄 Refreshed FCM Token: $newToken'); // <-- and here

          await _firestore.collection('user_tokens').doc(userId).update({
            'tokens': FieldValue.arrayUnion([newToken]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
      } else {
        debugPrint('🚫 Notification permission not granted');
      }
    } catch (e) {
      debugPrint('Push notification error: $e');
    }
  }


  // Cleanup on logout
  Future<void> _cleanupPushNotifications(String userId) async {
    try {
      final fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await _firestore.collection('user_tokens').doc(userId).update({
          'tokens': FieldValue.arrayRemove([fcmToken]),
        });
      }
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Token cleanup error: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      throw 'Failed to send password reset email';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _cleanupPushNotifications(user.uid);
      }
      await _auth.signOut();
      await _storage.deleteAll();
    } catch (e) {
      debugPrint("Sign out error: $e");
      rethrow;
    }
  }
}