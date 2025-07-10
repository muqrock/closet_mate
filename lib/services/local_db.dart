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
      version: 6, // ✅ bumped to version 6
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE outfits ADD COLUMN name TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE items ADD COLUMN brand TEXT');
          await db.execute('ALTER TABLE items ADD COLUMN size TEXT');
          await db.execute('ALTER TABLE items ADD COLUMN price TEXT');
          await db.execute('ALTER TABLE items ADD COLUMN tags TEXT');
          await db.execute('ALTER TABLE items ADD COLUMN colors TEXT');
          await db.execute('ALTER TABLE items ADD COLUMN private INTEGER');
          await db.execute('ALTER TABLE items ADD COLUMN datePurchased TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE items ADD COLUMN mainCategory TEXT');
        }
        if (oldVersion < 5 || oldVersion < 6) {
          // ✅ Upgrade outfits table to use accessoriesPath
          await db.execute('''
            CREATE TABLE new_outfits (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              accessoriesPath TEXT,
              topPath TEXT,
              bottomPath TEXT,
              shoesPath TEXT
            )
          ''');

          await db.execute('''
            INSERT INTO new_outfits (id, name, accessoriesPath, topPath, bottomPath, shoesPath)
            SELECT id, name, headPath, topPath, bottomPath, shoesPath FROM outfits
          ''');

          await db.execute('DROP TABLE outfits');
          await db.execute('ALTER TABLE new_outfits RENAME TO outfits');
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
        imagePath TEXT,
        category TEXT,
        mainCategory TEXT,
        brand TEXT,
        size TEXT,
        price TEXT,
        tags TEXT,
        colors TEXT,
        private INTEGER,
        datePurchased TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE outfits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        accessoriesPath TEXT,
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
      rethrow;
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

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateItem(Map<String, dynamic> item) async {
    try {
      final db = await database;
      final id = item['id'];

      final itemToUpdate = Map<String, dynamic>.from(item)..remove('id');

      final result = await db.update(
        'items',
        itemToUpdate,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result == 0) {
        print("❌ No item found with id: $id");
      } else {
        print("✅ Item updated successfully: $id");
      }
    } catch (e) {
      print("❌ Failed to update item: $e");
      rethrow;
    }
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

  // 📊 COUNTS
  Future<int> getItemCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM items'),
        ) ??
        0;
  }

  Future<int> getOutfitCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM outfits'),
        ) ??
        0;
  }
}
