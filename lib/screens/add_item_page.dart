import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AddItemPage extends StatefulWidget {
  final File imageFile;

  const AddItemPage({super.key, required this.imageFile});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  late Database _db;

  String _itemName = '';
  String _itemType = '';
  String _itemColor = '';

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
    );
  }

  Future<void> _saveItem() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final savedImage = await widget.imageFile.copy('${directory.path}/$fileName.jpg');

    await _db.insert('items', {
      'imagePath': savedImage.path,
      'name': _itemName,
      'type': _itemType,
      'color': _itemColor,
    });

    Navigator.pop(context, true); // Return to previous screen with refresh signal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item Details"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(widget.imageFile, height: 250, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
                onSaved: (value) => _itemName = value!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Item Type'),
                validator: (value) => value == null || value.isEmpty ? 'Enter type' : null,
                onSaved: (value) => _itemType = value!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) => value == null || value.isEmpty ? 'Enter color' : null,
                onSaved: (value) => _itemColor = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _saveItem();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Save Item", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
// This code defines an AddItemPage widget that allows users to add details for a wardrobe item.
// It includes a form to input item name, type, and color, and saves the item to a SQLite database.
// The image file is passed from the previous screen, and the item details are saved along with the image path.
// The user can navigate back to the previous screen after saving the item, which will refresh the wardrobe list.