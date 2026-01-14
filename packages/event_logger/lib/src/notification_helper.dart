import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({GlobalKey<NavigatorState>? navKey}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        navKey?.currentState?.pushNamed('/event-list');
      },
    );

    final NotificationAppLaunchDetails? launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         navKey?.currentState?.pushNamed('/event-list');
      });
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'event_logger_channel',
      'Event Logger Notifications',
      description: 'Notifications for the Event Logger package',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await requestNotificationPermission();
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        return status.isGranted;
    }
    return true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
      if (!(await requestNotificationPermission())) {
        print('Notification permission denied. Cannot show notification.');
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'event_logger_channel',
        'Event Logger Notifications',
        channelDescription: 'Notifications for the Event Logger package',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformChannelSpecifics,
      );
  }
}
