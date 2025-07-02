import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'wardrobe.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT,
            name TEXT,
            type TEXT,
            color TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE outfits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            itemIds TEXT
          );
        ''');
      },
    );
    return _database!;
  }
}