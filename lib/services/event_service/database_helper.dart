
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
        sourceScreen TEXT,
        destinationScreen TEXT,
        metadata TEXT,
        eventName TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        appName TEXT,
        sessionId TEXT
      )
    ''');
  }

  Future<int> insertEvent(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('events', row);
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    return await db.query('events');
  }
}
