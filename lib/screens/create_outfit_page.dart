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

  // Ordered categories from top to bottom (how people dress)
  final List<String> predefinedCategories = [
    'Accessories',
    'Tops',
    'Bottoms',
    'Footwear',
  ];

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _nameController.text = widget.outfit!['name'] ?? "";
      selectedImages = {
        'Tops': widget.outfit!['topPath'],
        'Bottoms': widget.outfit!['bottomPath'],
        'Footwear': widget.outfit!['shoesPath'],
        'Accessories': widget.outfit!['accessoriesPath'],
      };
    } else {
      selectedImages = {for (var cat in predefinedCategories) cat: null};
    }

    _loadItems();
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
      if (!isEditing) {
        selectedImages = {for (var cat in predefinedCategories) cat: null};
      }
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            builder:
                (_, controller) => SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            color: Colors.deepOrange,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Select $category",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      items.isEmpty
                          ? Container(
                            height: 200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "No items found. Please add one first.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio:
                                        0.65, // 👈 makes it more square/portrait
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return GestureDetector(
                                  onTap:
                                      () => _selectItem(
                                        category,
                                        item['imagePath'],
                                      ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // IMAGE takes up major vertical space
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Container(
                                              color: Colors.grey.shade100,
                                              child: Image.file(
                                                File(item['imagePath']),
                                                fit:
                                                    BoxFit
                                                        .contain, // fully visible
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // DETAILS
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['brand'] ?? 'No brand',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (item['size'] != null &&
                                                  item['size'] != '')
                                                Text(
                                                  "Size: ${item['size']}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              if (item['tags'] != null &&
                                                  item['tags']
                                                      .toString()
                                                      .isNotEmpty)
                                                Text(
                                                  "Tags: ${item['tags']}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                          ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildOutfitPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.preview, color: Colors.deepOrange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Outfit Preview",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_getSelectedItemsCount()}/4",
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Outfit visualization in vertical layout
          Column(
            children: [
              // Accessories
              _buildPreviewItem('Accessories', 80),
              const SizedBox(height: 12),

              // Tops
              _buildPreviewItem('Tops', 120),
              const SizedBox(height: 12),

              // Bottoms
              _buildPreviewItem('Bottoms', 120),
              const SizedBox(height: 12),

              // Footwear
              _buildPreviewItem('Footwear', 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String category, double height) {
    final imagePath = selectedImages[category];
    final hasItems = allItemsByCategory[category]?.isNotEmpty ?? false;

    return GestureDetector(
      onTap: () => _openSelectionSheet(category),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade50,
          border: Border.all(
            color:
                imagePath != null
                    ? Colors.deepOrange.withOpacity(0.3)
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: double.infinity,
                  fit:
                      BoxFit
                          .contain, // Changed from cover to contain for full visibility
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 24,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasItems
                          ? "Add ${category.toLowerCase()}"
                          : "No ${category.toLowerCase()}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Category label
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Remove button (only if item is selected)
            if (imagePath != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImages[category] = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _getSelectedItemsCount() {
    return selectedImages.values.where((path) => path != null).length;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Accessories':
        return Icons.watch;
      case 'Tops':
        return Icons.checkroom;
      case 'Bottoms':
        return Icons.dry_cleaning;
      case 'Footwear':
        return Icons.run_circle_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  void _saveOrUpdateOutfit() async {
    final name = _nameController.text.trim();

    // extract individual paths based on your DB schema
    final accessoriesPath = selectedImages['Accessories'];
    final topPath = selectedImages['Tops'];
    final bottomPath = selectedImages['Bottoms'];
    final shoesPath = selectedImages['Footwear'];

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter an outfit name."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if ([
      accessoriesPath,
      topPath,
      bottomPath,
      shoesPath,
    ].every((e) => e == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select at least one item."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final outfit = {
      'name': name,
      'accessoriesPath': accessoriesPath,
      'topPath': topPath,
      'bottomPath': bottomPath,
      'shoesPath': shoesPath,
    };

    try {
      if (isEditing) {
        await DBHelper.instance.updateOutfit(widget.outfit!['id'], outfit);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✅ Outfit updated!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        await DBHelper.instance.addOutfit(outfit);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✅ Outfit saved!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Outfit" : "Create Outfit"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outfit name input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit, color: Colors.deepOrange, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "Outfit Name",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Enter a name for your outfit...",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Outfit preview section
            _buildOutfitPreview(),
            const SizedBox(height: 24),

            // Save button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveOrUpdateOutfit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isEditing ? Icons.save_as : Icons.checkroom, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? "Update Outfit" : "Save Outfit",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
