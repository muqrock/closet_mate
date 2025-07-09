import 'dart:io';
import 'package:flutter/material.dart';
import '../services/local_db.dart';

class CreateOutfitPage extends StatefulWidget {
  final Map<String, dynamic>? outfit;

  const CreateOutfitPage({super.key, this.outfit});

  @override
  State<CreateOutfitPage> createState() => _CreateOutfitPageState();
}

class _CreateOutfitPageState extends State<CreateOutfitPage> {
  final TextEditingController _nameController = TextEditingController();
  Map<String, String?> selectedImages = {};
  Map<String, List<Map<String, dynamic>>> allItemsByCategory = {};

  bool get isEditing => widget.outfit != null;
  // Predefined categories for outfits
  final List<String> predefinedCategories = [
    'Tops',
    'Bottoms',
    'Footwear',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
    if (isEditing) {
      _nameController.text = widget.outfit!['name'] ?? "";
      selectedImages['Head'] = widget.outfit!['headPath'];
      selectedImages['Top'] = widget.outfit!['topPath'];
      selectedImages['Bottom'] = widget.outfit!['bottomPath'];
      selectedImages['Shoes'] = widget.outfit!['shoesPath'];
    }
  }

  Future<void> _loadItems() async {
    final items = await DBHelper.instance.getItems();
    final Map<String, List<Map<String, dynamic>>> categorizedItems = {
      for (var cat in predefinedCategories) cat: [],
    };

    for (var item in items) {
      final String? mainCategory = item['mainCategory'];
      if (mainCategory != null && categorizedItems.containsKey(mainCategory)) {
        categorizedItems[mainCategory]!.add(item);
      }
    }

    setState(() {
      allItemsByCategory = categorizedItems;
      selectedImages = {for (var cat in predefinedCategories) cat: null};
    });
  }

  void _selectItem(String category, String imagePath) {
    setState(() {
      selectedImages[category] = imagePath;
    });
    Navigator.pop(context);
  }

  void _openSelectionSheet(String category) {
    final items = allItemsByCategory[category] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child:
                items.isEmpty
                    ? const Center(
                      child: Text("No items found. Please add one first."),
                    )
                    : SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return GestureDetector(
                            onTap:
                                () => _selectItem(category, item['imagePath']),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(item['imagePath']),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
    );
  }

  Widget _buildImageRow(String category) {
    final imagePath = selectedImages[category];
    final hasItems = allItemsByCategory[category]?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              image:
                  imagePath != null
                      ? DecorationImage(
                        image: FileImage(File(imagePath)),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                imagePath == null
                    ? const Icon(Icons.image, size: 40, color: Colors.black26)
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!hasItems)
                  Text(
                    "No items yet. Add one first.",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.deepOrange,
            ),
            onPressed: () => _openSelectionSheet(category),
          ),
        ],
      ),
    );
  }

  void _saveOrUpdateOutfit() async {
    final name = _nameController.text.trim();

    // extract individual paths based on your DB schema
    final headPath = selectedImages['Head'];
    final topPath = selectedImages['Tops'];
    final bottomPath = selectedImages['Bottoms'];
    final shoesPath = selectedImages['Footwear'];

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an outfit name.")),
      );
      return;
    }

    if ([headPath, topPath, bottomPath, shoesPath].every((e) => e == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one item.")),
      );
      return;
    }

    final outfit = {
      'name': name,
      'headPath': headPath,
      'topPath': topPath,
      'bottomPath': bottomPath,
      'shoesPath': shoesPath,
    };

    try {
      if (isEditing) {
        await DBHelper.instance.updateOutfit(widget.outfit!['id'], outfit);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Outfit updated!")));
      } else {
        await DBHelper.instance.addOutfit(outfit);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Outfit saved!")));
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Outfit" : "Create Outfit"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Outfit Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ...allItemsByCategory.keys
                  .map((category) => _buildImageRow(category))
                  .toList(),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveOrUpdateOutfit,
                icon: Icon(isEditing ? Icons.save_as : Icons.checkroom),
                label: Text(isEditing ? "Update Outfit" : "Save Outfit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
