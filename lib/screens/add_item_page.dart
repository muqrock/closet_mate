import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/local_db.dart';

class AddItemsPage extends StatefulWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final bool isWeb;

  const AddItemsPage({Key? key, this.imageFile, this.imageBytes, required this.isWeb}) : super(key: key);


  @override
  State<AddItemsPage> createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final Map<String, List<String>> _itemsByCategory = {
    'Head': [],
    'Top': [],
    'Bottom': [],
    'Shoes': [],
    'Accessories': [],
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndAddImage(String category) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final path = image.path;

      // Save to SQLite
      await DBHelper.instance.addItem({
        'category': category,
        'imagePath': path,
      });

      setState(() {
        _itemsByCategory[category]!.add(path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItemsFromDB();
  }

  Future<void> _loadItemsFromDB() async {
    final items = await DBHelper.instance.getItems();
    for (var item in items) {
      final category = item['category'];
      final path = item['imagePath'];
      if (_itemsByCategory.containsKey(category)) {
        _itemsByCategory[category]!.add(path);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Your Items"),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              _itemsByCategory.keys.map((category) {
                final items = _itemsByCategory[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _pickAndAddImage(category),
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child:
                          items.isEmpty
                              ? const Center(child: Text("No items yet"))
                              : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: items.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(items[index]),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
