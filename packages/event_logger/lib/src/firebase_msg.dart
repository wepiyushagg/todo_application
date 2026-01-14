import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notification_helper.dart'; // Import the helper

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('--- BACKGROUND MESSAGE ---');
  print(message.notification?.title);
  print(message.notification?.body);
}

class FirebaseMsg {
  final FirebaseMessaging _msg = FirebaseMessaging.instance;
  final NotificationHelper _notificationHelper = NotificationHelper();

  Future<void> initFCM(GlobalKey<NavigatorState> navigatorKey) async {
    await _notificationHelper.init(navKey: navigatorKey);

    await _msg.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _msg.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    _msg.getInitialMessage().then((message) {
      if (message != null) {
        navigatorKey.currentState?.pushNamed('/event-list');
      }
    });
  }
  void _handleForegroundMessage(RemoteMessage message) {
    print('--- FOREGROUND FCM MESSAGE ---');
    print(message.notification?.title);
    print(message.notification?.body);

    final notification = message.notification;
    if (notification != null) {
      _notificationHelper.showNotification(
        title: notification.title ?? 'FCM Message',
        body: notification.body ?? 'You have a new message.',
      );
    }
  }
}
