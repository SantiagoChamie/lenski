import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

/// Small helper to centralize database path and opening logic.
/// Keeps a single place to change DB version/path behavior in the future.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const int dbVersion = 5;
  static const String dbFileName = 'lenski.db';

  Database? _database;

  /// Returns the path to the unified database file.
  Future<String> getDatabasePath() async {
    // Prefer path_provider when available
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = join(dir.path, dbFileName);
      return dbPath;
    } catch (_) {
      // Fallback to sqflite default path
      return join(await getDatabasesPath(), dbFileName);
    }
  }

  /// Opens (or returns cached) unified database instance.
  /// Uses a consistent version for all repositories.
  Future<Database> get database async {
    if (_database != null) return _database!;

    final path = await getDatabasePath();

    // Ensure directory exists
    final dbDirectory = Directory(dirname(path));
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }

    // Open DB without custom callbacks; repositories can still create/check tables.
    _database = await openDatabase(path, version: dbVersion);
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
