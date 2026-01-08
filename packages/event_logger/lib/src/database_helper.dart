import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

  Future<List<Map<String, dynamic>>> getAllEntries() async {
      final db = await database;
      return await db.query('events');
    }


  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await database;
    return await db.query('events', orderBy: 'timestamp DESC');
  }
}
