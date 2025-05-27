import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart'; // Update with your actual path


class FirebaseService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _setupPushNotificationsForCurrentUser();
  }

  static Future<void> _setupPushNotificationsForCurrentUser() async {
    final user = auth.currentUser;
    if (user == null) return;
    await _setupPushNotifications(user.uid);
  }

  static Future<void> _setupPushNotifications(String userId) async {
    try {
      final userDoc = firestore.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          await userDoc.update({
            'fcmToken': fcmToken,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        messaging.onTokenRefresh.listen((newToken) async {
          await userDoc.update({
            'fcmToken': newToken,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
      }
    } catch (e) {
      print('Error setting up push notifications: $e');
    }
  }



}




