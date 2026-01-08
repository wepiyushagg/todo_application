import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';
import 'notification_helper.dart';

class EventLoggerService {
  static final EventLoggerService _instance = EventLoggerService._internal();
  factory EventLoggerService() => _instance;
  EventLoggerService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationHelper _notificationHelper = NotificationHelper();

  Future<void> init() async {
    await _notificationHelper.init();
  }

  Future<void> logEvent({
    required String eventName,
    required String fromScreen,
    required String toScreen,
    Map<String, dynamic>? metadata,
  }) async {
    try {

      // Log to SQLite
      final id = await _dbHelper.insertEvent(
        eventName: eventName,
        fromScreen: fromScreen,
        toScreen: toScreen,
        metadata: metadata,
      );

      if (id > 0) {
        // Trigger notification
        await _notificationHelper.showNotification(
          title: 'Event Logged',
          body: 'Event \'$eventName\' has been logged successfully.',
        );
      }
    } catch (e) {
      // Handle potential errors
      print('Error logging event: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLocalEvents() async {
    return await _dbHelper.getEvents();
  }
}
