import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:html' as html; // For web only
import 'dart:typed_data';

import 'settings_page.dart';
import 'wardrobe_page.dart';
import 'add_item_page.dart';
import 'planner_page.dart';

import 'add_item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Uint8List? _selectedImageBytes; // For web image bytes
  XFile? _selectedImageFile; // For mobile

  final List<Widget> _pages = [
    const ProfileTab(),
    const WardrobePage(),
    const PlannerPage(),
    const SettingsPage(),
  ];

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddItemPage(imageFile: File(image.path)),
          ),
        );

        if (result == true) {
          // Refresh wardrobe manually if needed
        }
      }
    } catch (e) {
      print('Failed to pick image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
    Navigator.pop(context);
  }

  Future<void> _pickImageWeb() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          setState(() {
            _selectedImageBytes = reader.result as Uint8List?;
          });
          _navigateToAddItemPage();
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

  Future<void> _pickImageMobile(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });
        _navigateToAddItemPage();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  void _navigateToAddItemPage() {
    Navigator.pop(context); // Close bottom sheet

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddItemPage(
              imageFile: kIsWeb ? null : File(_selectedImageFile!.path),
              imageBytes: _selectedImageBytes,
              isWeb: kIsWeb,
            ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Add this method to fix the error
  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required MaterialColor color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color[100], // Use color[100] instead of shade100
        foregroundColor: color,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: _showAddOptionsDialog,
                backgroundColor: Colors.deepOrange,
                child: const Icon(Icons.add, size: 30),
                shape: const CircleBorder(),
                elevation: 6,
              )
              : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.wardrobe),
          label: 'Wardrobe',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Planner',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  void _showAddOptionsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'What would you like to do?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.add_box,
                  label: 'Add Item',
                  onPressed: () {
                    Navigator.pop(context);
                    _showImageSourceSelection();
                  },
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.checkroom,
                  label: 'Create Outfit',
                  onPressed: () {
                    Navigator.pop(context);
                    print('Create Outfit tapped');
                  },
                  color: Colors.orange,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required MaterialColor color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color[100], // Use color[100] instead of shade100
        foregroundColor: color,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose image source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (!kIsWeb)
                  _buildSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                    onPressed: () => _pickImageMobile(ImageSource.camera),
                    color: Colors.blue,
                  ),
                if (!kIsWeb) const SizedBox(height: 12),
                _buildSourceButton(
                  icon: Icons.photo_library,
                  label: 'Choose from Gallery',
                  onPressed:
                      kIsWeb
                          ? _pickImageWeb
                          : () => _pickImageMobile(ImageSource.gallery),
                  color: Colors.green,
                ),
              ],
            ),
          ),
    );
  }
}

// [Keep your existing ProfileTab implementation]

// Profile Tab with Firebase data
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return FutureBuilder<DocumentSnapshot>(
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

        return Column(
          children: [
            Container(
              color: const Color(0xFFFF914D),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/75.jpg',
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
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
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
                        _buildStatButton('items'),
                        _buildStatButton('outfits'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Scroll down for more features...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatButton(String type) {
    String label = type == 'items' ? 'Items' : 'Outfits';
    return Column(
      children: [
        const Text(
          '0',
          style: TextStyle(
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
}
// Settings Page
// This is a placeholder for the SettingsPage widget.