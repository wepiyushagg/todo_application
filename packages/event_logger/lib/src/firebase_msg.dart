import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'notification_helper.dart'; // Import the helper

final DatabaseHelper _dbHelper = DatabaseHelper();
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('--- BACKGROUND MESSAGE ---');
  final String eventname = message.notification?.title ?? 'unknown_event';
  String fromScreen = 'Home';
  String toScreen = 'notification';
  final Map<String, dynamic> metadata =
  message.data.isNotEmpty ? message.data : {
    'body': message.notification?.body ?? 'unknown_event',
  };
  final id = await _dbHelper.insertEvent(
    eventName: eventname,
    fromScreen: fromScreen,
    toScreen: toScreen,
    metadata: metadata,
  );

  print("Event logged successfully with id $id");
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
  void _handleForegroundMessage(RemoteMessage message) async { // Made async
    print('--- FOREGROUND FCM MESSAGE ---');
    print(message.notification?.title);
    print(message.notification?.body);

    final String eventname = message.notification?.title ?? 'unknown_event';
    String fromScreen = 'Home';
    String toScreen = 'notification';
    final Map<String, dynamic> metadata =
    message.data.isNotEmpty ? message.data : {
      'body': message.notification?.body ?? 'unknown_event',
    };
    // Added await to correctly get the ID
    final id = await _dbHelper.insertEvent(
      eventName: eventname,
      fromScreen: fromScreen,
      toScreen: toScreen,
      metadata: metadata,
    );

    print("Notification logged successfully with id: $id");

    final notification = message.notification;
    if (notification != null) {
      _notificationHelper.showNotification(
        title: notification.title ?? 'FCM Message',
        body: notification.body ?? 'You have a new message.',
      );
    }
  }
}
