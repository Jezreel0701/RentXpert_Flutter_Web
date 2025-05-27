import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:rentxpert_flutter_web/service/Firebase/Firebase_appNotification_model.dart';
import 'package:rentxpert_flutter_web/service/Firebase/chat_notification_service.dart';
import 'package:rentxpert_flutter_web/service/Firebase/firebase_service.dart';
import 'package:rentxpert_flutter_web/service/profileservice.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'auth/auth_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Stream<List<AppNotificationFirebase>> _notificationsStream;
  final String _currentUserId = FirebaseService.auth.currentUser?.uid ?? '';
  late final AuthService _authService;
  final ProfileService profileService = ProfileService();
  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _notificationsStream =
        NotificationRepository.getUserNotifications(_currentUserId);
    timeago.setLocaleMessages('en', timeago.EnMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A758F),
        iconTheme: const IconThemeData(color: Colors.white),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Provider.of<NavBarVisibilityProvider>(context, listen: false).showNavBar();
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: StreamBuilder<List<AppNotificationFirebase>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('No Notifications'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(AppNotificationFirebase notification) {
    final senderId = notification.senderId ?? '';
    final bool isUnread = notification.status != 'read';

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue[100] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          profileService.getUserProfilePhotoByUid(senderId),
          profileService.getFullnameByUid(senderId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Errors: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final photoUrl = snapshot.data?[0];
          final senderName = snapshot.data?[1];

          // Only make unread notifications tappable
          return isUnread
              ? GestureDetector(
            onTap: () {
              NotificationRepository.markAsRead(notification.id);
            },
            child: _buildNotificationContent(
              notification,
              photoUrl,
              senderName,
              isUnread,
            ),
          )
              : _buildNotificationContent(
            notification,
            photoUrl,
            senderName,
            isUnread,
          );
        },
      ),
    );
  }

  Widget _buildNotificationContent(AppNotificationFirebase notification,
      String? photoUrl,
      String? senderName,
      bool isUnread,) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                ? NetworkImage(photoUrl)
                : null,
            backgroundColor: Colors.grey,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? const Icon(Icons.person, size: 28, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        senderName ?? 'Unknown Sender',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(notification.timestamp),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notification.title ?? 'New message',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.body ?? 'You have a new message',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(notification.timestamp),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}