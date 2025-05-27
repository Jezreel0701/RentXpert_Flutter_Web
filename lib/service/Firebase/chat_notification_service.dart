import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/config.dart';
import 'Firebase_appNotification_model.dart';
import 'firebase_service.dart';

class ChatNotificationService {
  // static const int _maxRetryAttempts = 3;
  // static const Duration _initialRetryDelay = Duration(seconds: 1);
  static final Map<String, bool> _visibleConversations = {};
  // Matches your Go backend's FCMMessage structure
  static Map<String, dynamic> _createFCMPayload({
    required String fcmToken,
    required String title,
    required String body,
    required String senderId,
  }) {
    return {
      'fcmToken': fcmToken,
      'title': title,
      'body': body,
      'senderId': senderId,
    };
  }

  static Future<void> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    required String senderId,
  }) async {
    debugPrint('[FCM] === STARTING PUSH NOTIFICATION ===');
    debugPrint('[FCM] Token: ${fcmToken.substring(0, min(10, fcmToken.length))}...');
    debugPrint('[FCM] Title: $title');
    debugPrint('[FCM] Body: $body');
    debugPrint('[FCM] Sender: $senderId');

    try {

      final payload = _createFCMPayload(
        fcmToken: fcmToken,
        title: title,
        body: body,
        senderId: senderId,
      );

      debugPrint('[FCM] Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/send-notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      debugPrint('[FCM] Response: ${response.statusCode}');
      debugPrint('[FCM] Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      debugPrint('[FCM] Success! Response: $responseData');


    } catch (e, stackTrace) {
      debugPrint('[FCM] ERROR: $e');
      debugPrint('[FCM] Stack: $stackTrace');

      rethrow;
    }
  }

  static Future<void> trackNotificationOpen(String logId) async {
    debugPrint('[FCM] Tracking notification open for log: $logId');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/track-open/$logId'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        debugPrint('[FCM] Failed to track open: ${response.body}');
        return;
      }

      debugPrint('[FCM] Successfully tracked notification open');
    } catch (e) {
      debugPrint('[FCM] Error tracking open: $e');
    }
  }


  static Future<String> determineNotificationTitle(String receiverId) async {
    final logs = await FirebaseFirestore.instance
        .collection('notification_logs')
        .where('receiver_id', isEqualTo: receiverId)
        .limit(1)
        .get();

    final hasExistingLog = logs.docs.isNotEmpty;


    if (!hasExistingLog) {
      // First time — choose dynamic title
        return "RentXpert";
    }

    // Default fallback title
    return "New Message";
  }

  static Future<String?> getFcmToken(String userId) async {
    try {
      // 1. First try to get from user_tokens collection
      final tokensDoc = await FirebaseService.firestore
          .collection('user_tokens')
          .doc(userId)
          .get();

      if (tokensDoc.exists) {
        final tokens = tokensDoc.data()?['tokens'];

        // Handle case where tokens is a List
        if (tokens is List && tokens.isNotEmpty) {
          // Return the most recent token (assuming last in array is newest)
          return tokens.last.toString();
        }

        // Handle case where tokens might be a single string
        if (tokens is String) {
          return tokens;
        }
      }

      // 2. Fallback to check users collection
      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final token = userDoc.data()?['fcmToken'];
        if (token is String) {
          return token;
        }
      }

      debugPrint('[Notification] No valid FCM token found for user $userId');
      return null;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  static String _truncateMessage(String message) {
    return message.length > 30 ? '${message.substring(0, 30)}...' : message;
  }

  static void setupNotificationListeners() {

    // Handle when notification is opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final logId = message.data['logId'];

      debugPrint('📬 Notification opened with data: ${message.data}');
      debugPrint('🔍 Extracted logId: $logId');

      if (logId != null) {
        trackNotificationOpen(logId);
      }

      // Add navigation logic here if needed

      // navigatorKey.currentState?.push(
      //   MaterialPageRoute(
      //       builder: (_) => RentalMap()
      //   ),
      // );
    });

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message while in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Notification: ${message.notification?.title}');
        debugPrint('Notification: ${message.notification?.body}');
      }
    });
  }
}

class NotificationRepository {
  static Stream<List<AppNotificationFirebase>> getUserNotifications(String userId) {
    return FirebaseService.firestore
        .collection('notification_logs')
        .where('receiver_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppNotificationFirebase.fromFirestore(doc))
        .toList());
  }

  static Future<void> markAsRead(String notificationId) async {
    await FirebaseService.firestore
        .collection('notification_logs')
        .doc(notificationId)
        .update({
      'status': 'read',
      'read_at': FieldValue.serverTimestamp(),
    });
  }

}