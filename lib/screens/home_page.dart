import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:image_picker/image_picker.dart';
// Add this (only for web)
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:io';

import 'add_item_page.dart';
import '../services/local_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'wardrobe_page.dart';
import 'planner_page.dart';

import 'settings_page.dart';
import 'create_outfit_page.dart'; // Add this import if the class exists in this file

class HomePage extends StatefulWidget {
  final String? initialImagePath;
  final bool navigateToAddItem;

  const HomePage({
    super.key,
    this.initialImagePath,
    this.navigateToAddItem = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  XFile? _selectedImage;

  final List<Widget> _pages = [
    const ProfileTab(),
    const WardrobePage(), // ← Now uses actual page
    const PlannerPage(), // ← Now uses actual page
    const SettingsPage(),
  ];

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });

        Navigator.pop(context); // Close the bottom sheet

        final Uint8List? bytes = kIsWeb ? await image.readAsBytes() : null;

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AddItemPage(
                  isWeb: kIsWeb,
                  imageFile: kIsWeb ? null : File(image.path),
                  imageBytes: bytes,
                ),
          ),
        ).then((result) {
          if (result == true) {
            // 👇 Refresh state manually
            setState(() {
              _pages[0] = const ProfileTab(); // reload ProfileTab
            });
          }
        });
      }
    } catch (e) {
      print('Failed to pick image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () => _showAddOptionsDialog(context),
                backgroundColor: Colors.deepOrange,
                shape: const CircleBorder(),
                elevation: 6,
                child: const Icon(Icons.add, size: 30),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.tshirtCrew),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Show options to add item or create outfit
  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'What would you like to do?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  _showImageSourceSelection(
                    context,
                  ); // 🪄 Now opens camera/gallery selection
                },
                icon: const Icon(Icons.add_box),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOutfitPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.checkroom),
                label: const Text('Create Outfit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose image source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Profile Tab with Firebase data
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

String _selectedCategory = 'All';
Set<String> _availableCategories = {'All'};

class _ProfileTabState extends State<ProfileTab> {
  int _itemCount = 0;
  int _outfitCount = 0;

  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadCounts();
    _loadItems(); // 👈 Load saved items
  }

  Future<void> _loadItems() async {
    final dbHelper = DBHelper.instance;
    final loadedItems = await dbHelper.getItems();

    final categories = <String>{'All'};
    for (var item in loadedItems) {
      final category = item['category'] ?? '';
      if (category.isNotEmpty) {
        if (category.toLowerCase().contains('top')) {
          categories.add('Tops');
        } else if (category.toLowerCase().contains('bottom') ||
            category.toLowerCase().contains('pants') ||
            category.toLowerCase().contains('jeans')) {
          categories.add('Bottoms');
        } else {
          categories.add(category);
        }
      }
    }

    setState(() {
      _items = loadedItems;
      _availableCategories = categories;
    });
  }

  Future<void> _loadCounts() async {
    final dbHelper =
        DBHelper.instance; // Use the named constructor or singleton instance
    final itemCount = await dbHelper.getItemCount();
    final outfitCount = await dbHelper.getOutfitCount();
    setState(() {
      _itemCount = itemCount;
      _outfitCount = outfitCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCounts,
            tooltip: 'Refresh Counts',
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final fullName = userData['fullName'] ?? 'No Name';
          final username = userData['username'] ?? 'No Username';
          final filteredItems =
              _selectedCategory == 'All'
                  ? _items
                  : _items.where((item) {
                    final category =
                        (item['category'] ?? '').toString().toLowerCase();
                    if (_selectedCategory == 'Tops') {
                      return category.contains('top');
                    } else if (_selectedCategory == 'Bottoms') {
                      return category.contains('bottom') ||
                          category.contains('pants') ||
                          category.contains('jeans');
                    }
                    return category == _selectedCategory.toLowerCase();
                  }).toList();

          return Column(
            children: [
              Container(
                // 🔸 Orange profile header
                color: const Color(0xFFFF914D),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(
                        'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '@$username',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Items', _itemCount),
                          _buildStatCard('Outfits', _outfitCount),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🎯 PUT THE CATEGORY FILTER WIDGET HERE
              if (_items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children:
                          _availableCategories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                selectedColor: Colors.deepOrange,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),

              // 📦 THEN THE ITEM LIST BELOW
              Expanded(
                child:
                    _items.isEmpty
                        ? const Center(child: Text('No items found'))
                        : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount:
                              filteredItems.length, // ← use filtered list
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _buildItemCard(item);
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child:
                  item['imagePath'] != null &&
                          File(item['imagePath']).existsSync()
                      ? Image.file(File(item['imagePath']), fit: BoxFit.cover)
                      : const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['brand'] ?? 'No Brand',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  item['category'] ?? 'Unknown Category',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
