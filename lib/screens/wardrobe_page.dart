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
    _loadData();
  }

  Future<void> _loadData() async {
    final outfits = await DBHelper.instance.getAllOutfits();
    setState(() {
      _outfits = outfits;
    });
  }

  Future<void> _deleteOutfit(int id) async {
    await DBHelper.instance.deleteOutfit(id);
    _loadData();
  }

  void _confirmDeleteOutfit(BuildContext context, int id) {
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
                if (outfit['accessoriesPath'] != null)
                  _buildOutfitItemImage(outfit['accessoriesPath']),
                if (outfit['topPath'] != null)
                  _buildOutfitItemImage(outfit['topPath']),
                if (outfit['bottomPath'] != null)
                  _buildOutfitItemImage(outfit['bottomPath']),
                if (outfit['shoesPath'] != null)
                  _buildOutfitItemImage(outfit['shoesPath']),
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

  Widget _buildOutfitItemImage(String path) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(path),
          fit: BoxFit.contain,
          width: double.infinity,
          height: 220, // adjust to your preferred height
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 220,
              width: double.infinity,
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image,
                color: Color(0xFFCCCCCC),
                size: 48,
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
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
                    const Text(
                      "My Outfits",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Manage your outfit collection",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            _outfits.isEmpty
                ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
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
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
                : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final outfit = _outfits[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: GestureDetector(
                        onTap: () => _showOutfitDetails(outfit),
                        child: Container(
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
                              if (outfit['accessoriesPath'] != null)
                                _buildOutfitItemImage(
                                  outfit['accessoriesPath'],
                                ),
                              if (outfit['topPath'] != null)
                                _buildOutfitItemImage(outfit['topPath']),
                              if (outfit['bottomPath'] != null)
                                _buildOutfitItemImage(outfit['bottomPath']),
                              if (outfit['shoesPath'] != null)
                                _buildOutfitItemImage(outfit['shoesPath']),
                              const SizedBox(height: 12),
                              Text(
                                outfit['name'] ?? "Unnamed Outfit",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextButton.icon(
                                      onPressed:
                                          () => _confirmDeleteOutfit(
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
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFE0B2),
                                      borderRadius: BorderRadius.circular(12),
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
                                        if (result == true) _loadData();
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
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: _outfits.length),
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
              MaterialPageRoute(builder: (_) => const CreateOutfitPage()),
            );
            if (result == true) {
              _loadData(); // Reload data if outfit added/edited
            }
          },
          label: const Text(
            "Create Outfit",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xFFFF5722),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
