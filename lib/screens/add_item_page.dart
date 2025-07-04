import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase_flutter; // <--- ADD 'as supabase_flutter' here
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:firebase_auth/firebase_auth.dart'; // This import remains as is

class AddItemPage extends StatefulWidget {
  final File? imageFile; // For mobile/desktop
  final Uint8List? imageBytes; // For web
  final bool isWeb;

  const AddItemPage({
    super.key,
    this.imageFile,
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

  final Uuid _uuid = const Uuid(); // Initialize Uuid for unique IDs
  // Now, SupabaseClient is available directly because it's not conflicted
  final supabase_flutter.SupabaseClient supabase =
      supabase_flutter.Supabase.instance.client; // <--- USE THE PREFIX HERE

  @override
  void dispose() {
    _brandController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
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

  Future<void> _saveItem() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated')),
      );
      return;
    }

    // 1. Create user-specific folder path
    final String userFolder = user.uid; // Firebase UID as folder name
    final String itemId = _uuid.v4();
    final String imagePath = '$userFolder/$itemId.png'; // Nested path

    try {
      // 2. Upload to user's folder
      if (kIsWeb && widget.imageBytes != null) {
        await supabase.storage.from('outfitimage').uploadBinary(
              imagePath,
              widget.imageBytes!,
              fileOptions: const supabase_flutter.FileOptions(
                contentType: 'image/png',
              ),
            );
      } else if (widget.imageFile != null) {
        await supabase.storage.from('outfitimage').upload(
              imagePath,
              widget.imageFile!,
              fileOptions: const supabase_flutter.FileOptions(
                contentType: 'image/png',
              ),
            );
      }

      // 3. Get public URL (if bucket is public)
      final imageUrl =
          supabase.storage.from('outfitimage').getPublicUrl(imagePath);

      // 4. Save to database
      await supabase.from('items').insert({
        'id': itemId,
        'user_id': user.uid,
        'image_path': imagePath, // Store the full path
        // ... other fields
      });
    } catch (e) {
      print('Upload error: $e');
    }
  }

  void _showSizePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final sizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'];

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: sizes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final size = sizes[index];
            return ListTile(
              title: Text(size),
              onTap: () {
                setState(() {
                  _sizeController.text = size;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildImagePreview() {
    // This now uses kIsWeb directly, which is generally more robust
    if (kIsWeb) {
      if (widget.imageBytes != null) {
        return Image.memory(widget.imageBytes!, height: 200);
      } else {
        return const Icon(Icons.error, size: 200, color: Colors.red);
      }
    } else {
      // Assuming non-web platforms always have imageFile
      if (widget.imageFile != null) {
        return Image.file(widget.imageFile!, height: 200);
      } else {
        return const Icon(Icons.error, size: 200, color: Colors.red);
      }
    }
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
              items: ['T-shirt', 'Pants', 'Outerwear', 'Shoes']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            _buildLabel('Colors'),
            Wrap(
              spacing: 8,
              children: _colors
                  .map(
                    (color) => Chip(
                      label: Text(color),
                      onDeleted: () => setState(() => _colors.remove(color)),
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
              children: _tags
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
            GestureDetector(
              onTap: _showSizePicker,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _sizeController,
                  decoration: const InputDecoration(
                    hintText: 'Select size',
                    suffixIcon: Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ),
            ),
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
                    onPressed: () {
                      print('Review later');
                      Navigator.pop(context);
                    },
                    child: const Text('Review Later'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _saveItem, // This calls the Supabase saving logic
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
