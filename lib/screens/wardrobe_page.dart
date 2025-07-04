import 'dart:io';
import 'dart:typed_data'; // Required for Uint8List in web image picking
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase_flutter; // Use alias
import 'package:firebase_auth/firebase_auth.dart'; // To get the current user's UID

import 'add_item_page.dart'; // Make sure this path is correct

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  // Supabase client instance
  final supabase_flutter.SupabaseClient supabase =
      supabase_flutter.Supabase.instance.client;

  // List to hold fetched items from Supabase
  List<Map<String, dynamic>> _items = [];

  // Boolean to track loading state
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchItems(); // Fetch items when the page initializes
  }

  // Fetches items from the Supabase 'items' table
  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'Please log in to view your wardrobe.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch data from 'items' table, ordered by 'created_at' descending
      // Filter by the current Firebase user's UID
      final List<Map<String, dynamic>> data = await supabase
          .from('items')
          .select('*') // Select all columns
          .eq('user_id', currentUser.uid) // Filter by Firebase UID
          .order('created_at', ascending: false); // Order by creation date

      setState(() {
        _items = data;
        _isLoading = false;
      });
    } on supabase_flutter.PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Error fetching items: ${e.message}';
        _isLoading = false;
      });
      print('Supabase PostgrestException fetching items: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
      print('An unexpected error fetching items: $e');
    }
  }

  // Deletes an item from Supabase database and storage
  Future<void> _deleteItem(String itemId, String imageUrl) async {
    try {
      // 1. Delete the image from Supabase Storage
      // Extract the file name from the URL
      final Uri uri = Uri.parse(imageUrl);
      final String imageFileName = uri.pathSegments.last;

      await supabase.storage.from('outfit_images').remove([imageFileName]);
      print('Image deleted from Supabase Storage: $imageFileName');

      // 2. Delete the record from the Supabase database
      await supabase.from('items').delete().eq('id', itemId);
      print('Item deleted from Supabase Database: $itemId');

      // Refresh the list after successful deletion
      _fetchItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully!')),
      );
    } on supabase_flutter.StorageException catch (e) {
      print('Supabase Storage Error during deletion: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: ${e.message}')),
      );
    } on supabase_flutter.PostgrestException catch (e) {
      print('Supabase Database Error during deletion: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item data: ${e.message}')),
      );
    } catch (e) {
      print('An unexpected error occurred during deletion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred during deletion: $e')),
      );
    }
  }

  Future<void> _pickImageAndAddItem() async {
    final ImagePicker picker = ImagePicker();
    XFile? image;

    // Pick image from gallery
    try {
      image = await picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      return;
    }

    // Explicitly check if image is null. If it is, the user cancelled.
    if (image == null) {
      return; // User cancelled image selection, so exit the function
    }

    Object? result;
    if (kIsWeb) {
      // For web, image.readAsBytes() returns a Future<Uint8List>
      final Uint8List bytes = await image.readAsBytes();
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddItemPage(
            imageBytes: bytes,
            isWeb: true,
          ),
        ),
      );
    } else {
      // For mobile, we create a File from image.path
      // We use '!' here because we've already checked 'image == null' above.
      // This tells the analyzer that 'image' is definitely not null here.
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddItemPage(
            imageFile:
                File(image!.path), // <--- Use null assertion operator here
            isWeb: false,
          ),
        ),
      );
    }
    // If AddItemPage returns true, it means an item was successfully saved
    if (result == true) {
      _fetchItems(); // Refresh items after adding
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _fetchItems,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? const Center(
                      child: Text('No items in your wardrobe yet. Add some!'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return GestureDetector(
                          // Using item['id'] which is a String (UUID) from Supabase
                          onLongPress: () =>
                              _showDeleteDialog(item['id'], item['image_url']),
                          child: Card(
                            // Changed to Card for a nicer look
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    // Use Image.network for Supabase URLs
                                    child: Image.network(
                                      item[
                                          'image_url'], // Get image URL from Supabase data
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 50, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['category'] ??
                                            'N/A', // Display category
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item['brand'] ??
                                            'No brand', // Display brand
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Size: ${item['size'] ?? 'N/A'}', // Display size
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                      ),
                                      // Display colors (convert List<String> to a comma-separated string)
                                      if (item['colors'] != null &&
                                          item['colors'] is List &&
                                          item['colors'].isNotEmpty)
                                        Text(
                                          'Colors: ${(item['colors'] as List).join(', ')}',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      // Display tags (convert List<String> to a comma-separated string)
                                      if (item['tags'] != null &&
                                          item['tags'] is List &&
                                          item['tags'].isNotEmpty)
                                        Text(
                                          'Tags: ${(item['tags'] as List).join(', ')}',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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

  // Changed id to String type as Supabase uses UUIDs for 'id'
  void _showDeleteDialog(String id, String imageUrl) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
              _deleteItem(id, imageUrl); // Pass id and imageUrl
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
