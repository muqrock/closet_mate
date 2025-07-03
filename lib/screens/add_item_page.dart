import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddItemPage extends StatefulWidget {
  final File imageFile;

  const AddItemPage({super.key, required this.imageFile});

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
    print('Saving item...');
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
            Center(child: Image.file(widget.imageFile, height: 200)),
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
