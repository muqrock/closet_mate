import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  late Database _db;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'wardrobe.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT
          )
        ''');
      },
    );
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final data = await _db.query('items');
    setState(() {
      _items = data;
    });
  }

  Future<void> _addItem(XFile file) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final savedImage = await File(file.path).copy('${directory.path}/$fileName.jpg');

    await _db.insert('items', {'imagePath': savedImage.path});
    _fetchItems();
  }

  Future<void> _deleteItem(int id, String imagePath) async {
    await File(imagePath).delete();
    await _db.delete('items', where: 'id = ?', whereArgs: [id]);
    _fetchItems();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _addItem(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wardrobe"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('No items yet.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onLongPress: () => _showDeleteDialog(item['id'], item['imagePath']),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item['imagePath']),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteDialog(int id, String imagePath) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteItem(id, imagePath);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
// This code defines a WardrobePage widget that allows users to manage their wardrobe items.
// It includes functionality to add items by picking images from the gallery, display them in a grid,