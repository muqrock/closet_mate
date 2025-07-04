import 'dart:io';
import 'package:flutter/material.dart';
import 'create_outfit_page.dart';
import '../services/local_db.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  List<Map<String, dynamic>> _outfits = [];

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    final outfits = await DBHelper.instance.getAllOutfits();
    setState(() {
      _outfits = outfits;
    });
  }

  Future<void> _deleteOutfit(int id) async {
    await DBHelper.instance.deleteOutfit(id);
    _loadOutfits();
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Delete Outfit",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            content: const Text(
              "Are you sure you want to delete this outfit?",
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF999999),
                ),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteOutfit(id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  void _showOutfitDetails(Map<String, dynamic> outfit) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              outfit['name'] ?? "Unnamed Outfit",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (outfit['headPath'] != null)
                  _buildItemImage(outfit['headPath']),
                if (outfit['topPath'] != null)
                  _buildItemImage(outfit['topPath']),
                if (outfit['bottomPath'] != null)
                  _buildItemImage(outfit['bottomPath']),
                if (outfit['shoesPath'] != null)
                  _buildItemImage(outfit['shoesPath']),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF999999),
                ),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  Widget _buildItemImage(String path) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          height: 80,
          width: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.broken_image,
                color: Color(0xFFCCCCCC),
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFFF914D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "My Outfits",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_outfits.length}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your wardrobe collection",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Body Content
            Expanded(
              child:
                  _outfits.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.checkroom_outlined,
                                size: 48,
                                color: Color(0xFFFF5722),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No outfits yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Create your first outfit to get started!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _outfits.length,
                        itemBuilder: (context, index) {
                          final outfit = _outfits[index];
                          return GestureDetector(
                            onTap: () => _showOutfitDetails(outfit),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFFF0F0F0),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Images Column (Wardrobe Style)
                                  Column(
                                    children: [
                                      if (outfit['headPath'] != null)
                                        _buildItemImage(outfit['headPath']),
                                      if (outfit['topPath'] != null)
                                        _buildItemImage(outfit['topPath']),
                                      if (outfit['bottomPath'] != null)
                                        _buildItemImage(outfit['bottomPath']),
                                      if (outfit['shoesPath'] != null)
                                        _buildItemImage(outfit['shoesPath']),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Outfit Name
                                  Text(
                                    outfit['name'] ?? "Unnamed Outfit",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Action Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Delete Button
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: TextButton.icon(
                                          onPressed:
                                              () => _confirmDelete(
                                                context,
                                                outfit['id'],
                                              ),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Edit Button
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE0B2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => CreateOutfitPage(
                                                      outfit: outfit,
                                                    ),
                                              ),
                                            );
                                            if (result == true) _loadOutfits();
                                          },
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xFFFF5722),
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "Edit",
                                            style: TextStyle(
                                              color: Color(0xFFFF5722),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5722).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateOutfitPage()),
            );
            if (result == true) {
              _loadOutfits();
            }
          },
          label: const Text(
            "Add Outfit",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xFFFF5722),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
