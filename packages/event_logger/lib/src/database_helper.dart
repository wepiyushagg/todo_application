import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'event_logger.db');
    developer.log('Database path: $path', name: 'DatabaseHelper');
    developer.log('You can use a device file explorer to check if this file persists across app launches.', name: 'DatabaseHelper');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    developer.log('onCreate: Creating new database and events table because it does not exist.', name: 'DatabaseHelper');
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventName TEXT NOT NULL,
        fromScreen TEXT NOT NULL,
        toScreen TEXT NOT NULL,
        metadata TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<int> insertEvent({
    required String eventName,
    required String fromScreen,
    required String toScreen,
    Map<String, dynamic>? metadata,
  }) async {
    final db = await database;
    return await db.insert('events', {
      'eventName': eventName,
      'fromScreen': fromScreen,
      'toScreen': toScreen,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    });
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await database;
    return await db.query('events', orderBy: 'timestamp DESC');
  }
  Future<List<Map<String, dynamic>>> getAllEntries() async {
    final db = await database;
    return await db.query('events', orderBy: 'id');
  }

  /// Deletes all events from the events table.
  Future<void> deleteAllEvents() async {
    final db = await database;
    await db.delete('events');
    developer.log('All events deleted from the database.', name: 'DatabaseHelper');
  }

  /// Deletes the entire database file.
  /// This will cause the database and tables to be recreated on next launch.
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'event_logger.db');
    await deleteDatabase(path);
    _database = null; // Force re-initialization
    developer.log('Database file deleted.', name: 'DatabaseHelper');
  }
}
