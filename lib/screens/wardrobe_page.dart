import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart'; // Add this for kIsWeb

import 'add_item_page.dart';

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
            imagePath TEXT,
            name TEXT,
            type TEXT,
            color TEXT
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

  Future<void> _deleteItem(int id, String imagePath) async {
    if (!kIsWeb) {
      await File(imagePath).delete();
    }
    await _db.delete('items', where: 'id = ?', whereArgs: [id]);
    _fetchItems();
  }

  Future<void> _pickImageAndAddItem() async {
    if (kIsWeb) {
      _pickImageWeb();
    } else {
      _pickImageMobile();
    }
  }

  Future<void> _pickImageMobile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => AddItemPage(
                imageFile: File(image.path),
                isWeb: false, // Added required parameter
              ),
        ),
      );
      if (result == true) {
        _fetchItems();
      }
    }
  }

  Future<void> _pickImageWeb() async {
    // Web implementation would go here
    // You'll need to handle web image picking differently
    // This is just a placeholder
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddItemPage(
              imageBytes: Uint8List(0), // Replace with actual bytes
              isWeb: true, // Added required parameter
            ),
      ),
    );
    if (result == true) {
      _fetchItems();
    }
  }

  Widget _buildImageWidget(String imagePath) {
    if (kIsWeb) {
      // For web, you'll need to store and retrieve images differently
      // This is just a placeholder
      return Image.network(imagePath); // Or use Image.memory() for bytes
    } else {
      return Image.file(File(imagePath));
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
            onPressed: _pickImageAndAddItem,
          ),
        ],
      ),
      body:
          _items.isEmpty
              ? const Center(child: Text('No items yet.'))
              : GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return GestureDetector(
                    onLongPress:
                        () => _showDeleteDialog(item['id'], item['imagePath']),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: _buildImageWidget(item['imagePath']),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item['type'] ?? '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  item['color'] ?? '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
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
      builder:
          (dialogContext) => AlertDialog(
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
