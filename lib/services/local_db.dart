import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  static Database? _db;

  DBHelper._internal();

  // 📦 Get or initialize DB
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'closetmate.db');
    return await openDatabase(
      path,
      version: 2, // ⬆️ bumped version to add name column to outfits
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE outfits ADD COLUMN name TEXT');
        }
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT,
        username TEXT UNIQUE,
        email TEXT UNIQUE,
        password TEXT,
        gender TEXT,
        birthday TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE outfits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        headPath TEXT,
        topPath TEXT,
        bottomPath TEXT,
        shoesPath TEXT
      )
    ''');
  }

  // 👕 ITEMS METHODS
  Future<int> addItem(Map<String, dynamic> item) async {
    try {
      final db = await database;
      return await db.insert('items', item);
    } catch (e) {
      print("❌ Failed to insert item: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('items');
  }

  Future<void> clearAllItems() async {
    final db = await database;
    await db.delete('items');
    print("🧺 All wardrobe items cleared");
  }

  // 🧥 OUTFIT METHODS
  Future<int> addOutfit(Map<String, dynamic> outfit) async {
    final db = await database;
    return await db.insert('outfits', outfit);
  }

  Future<int> updateOutfit(int id, Map<String, dynamic> outfit) async {
    final db = await database;
    return await db.update('outfits', outfit, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllOutfits() async {
    final db = await database;
    return await db.query('outfits');
  }

  Future<void> clearAllOutfits() async {
    final db = await database;
    await db.delete('outfits');
    print("🧺 All outfits cleared");
  }

  Future<int> deleteOutfit(int id) async {
    final db = await database;
    return await db.delete('outfits', where: 'id = ?', whereArgs: [id]);
  }

  // 📊 ITEM & OUTFIT COUNTS
  Future<int> getItemCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM items'),
    ) ?? 0;
  }

  Future<int> getOutfitCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM outfits'),
    ) ?? 0;
  }
}
