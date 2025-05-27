import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationFirebase {
  final String id;
  final String receiverId;
  final String? senderId;
  final String conversationId;
  final String? fcmMessageId;
  final String status;
  final String? error;
  final DateTime timestamp;
  final int? deliveryAttempt;
  final String? title;
  final String? body;

  AppNotificationFirebase({
    required this.id,
    required this.receiverId,
    this.senderId,
    required this.conversationId,
    this.fcmMessageId,
    required this.status,
    this.error,
    required this.timestamp,
    this.deliveryAttempt,
    this.title,
    this.body,
  });

  factory AppNotificationFirebase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotificationFirebase(
      id: doc.id,
      receiverId: data['receiver_id'] ?? 'unknown',
      senderId: data['sender_id'],
      conversationId: data['conversation_id'] ?? '',
      fcmMessageId: data['fcm_message_id'],
      status: data['status'] ?? 'unknown',
      error: data['error'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      deliveryAttempt: data['delivery_attempt'],
      title: data['title'],
      body: data['body'],
    );
  }
}