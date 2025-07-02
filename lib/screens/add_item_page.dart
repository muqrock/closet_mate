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
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class AddItemPage extends StatefulWidget {
  final File? imageFile; // For mobile/desktop
  final String? imagePath; // For web (network URL)
  final Uint8List? imageBytes; // For web (bytes)
  final bool isWeb;

  const AddItemPage({
    super.key,
    this.imageFile,
    this.imagePath,
    this.imageBytes,
    required this.isWeb,
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedCategory = 'T-shirt';
  bool _private = true;

  final List<String> _colors = [];
  final List<String> _tags = [];

  Widget _buildImagePreview() {
    if (widget.isWeb) {
      if (widget.imageBytes != null) {
        return Image.memory(widget.imageBytes!, height: 200);
      } else if (widget.imagePath != null) {
        return Image.network(widget.imagePath!, height: 200);
      } else {
        return const Icon(Icons.error, size: 200, color: Colors.red);
      }
    } else {
      return Image.file(widget.imageFile!, height: 200);
    }
  }

  void _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _addColor(String color) {
    if (!_colors.contains(color)) {
      setState(() => _colors.add(color));
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag.trim()));
    }
  }

  void _saveItem() {
    // TODO: Upload to Firestore and Storage
    // Handle web vs mobile differently for upload
    if (widget.isWeb) {
      print('Saving web image...');
      if (widget.imageBytes != null) {
        // Upload bytes for web
      } else if (widget.imagePath != null) {
        // Upload from URL for web
      }
    } else {
      print('Saving mobile image file...');
      // Upload File for mobile
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildImagePreview()),
            const SizedBox(height: 20),

            _buildLabel('Category'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items:
                  ['T-shirt', 'Pants', 'Outerwear', 'Shoes']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),

            const SizedBox(height: 16),
            _buildLabel('Colors'),
            Wrap(
              spacing: 8,
              children:
                  _colors
                      .map(
                        (color) => Chip(
                          label: Text(color),
                          onDeleted:
                              () => setState(() => _colors.remove(color)),
                        ),
                      )
                      .toList(),
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Add a color'),
              onSubmitted: _addColor,
            ),

            const SizedBox(height: 16),
            _buildLabel('Tags'),
            Wrap(
              spacing: 8,
              children:
                  _tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                        ),
                      )
                      .toList(),
            ),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(hintText: 'Add a tag'),
              onSubmitted: (value) {
                _addTag(value);
                _tagsController.clear();
              },
            ),

            const SizedBox(height: 16),
            _buildLabel('Brand'),
            TextField(controller: _brandController),

            const SizedBox(height: 16),
            _buildLabel('Size'),
            TextField(controller: _sizeController),

            const SizedBox(height: 16),
            _buildLabel('Price'),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: 'RM '),
            ),

            const SizedBox(height: 16),
            _buildLabel('Date Purchased'),
            Row(
              children: [
                Text(
                  _selectedDate == null
                      ? 'No date selected'
                      : DateFormat.yMMMd().format(_selectedDate!),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Select Date'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildLabel('Visibility'),
            SwitchListTile(
              title: const Text('Private'),
              value: _private,
              onChanged: (val) => setState(() => _private = val),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Review Later'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}
