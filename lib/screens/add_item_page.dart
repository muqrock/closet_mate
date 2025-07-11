import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/local_db.dart';
import 'home_page.dart'; // Adjust path if it's in another folder

class AddItemPage extends StatefulWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final bool isWeb;
  final Map<String, dynamic>? existingItem;

  const AddItemPage({
    super.key,
    this.imageFile,
    this.imageBytes,
    required this.isWeb,
    this.existingItem,
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  final Map<String, List<String>> _categoryMap = {
    'Tops': ['T-shirt', 'Hoodie', 'Activewear', 'Other'],
    'Bottoms': ['Skirts', 'Trouser', 'Shorts', 'Jeans', 'Activewear', 'Other'],
    'Outerwear': ['Coats', 'Jackets', 'Capes', 'Other'],
    'Underwear & Nightwear': ['Underwear', 'Nightwear'],
    'Accessories': ['Ties', 'Scarves', 'Gloves', 'Socks', 'Other'],
    'Footwear': ['Flats', 'Sandals', 'Boots', 'Sport Shoes', 'Other'],
  };

  String? _selectedMainCategory;
  String? _selectedSubCategory;
  DateTime? _selectedDate;
  final List<String> _colors = [];
  final List<String> _tags = [];

  // Image related variables
  File? _currentImageFile;
  Uint8List? _currentImageBytes;
  String? _existingImagePath;
  bool _imageChanged = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeImage();
    if (widget.existingItem != null) {
      _initializeExistingItem();
    }
  }

  void _initializeImage() {
    if (widget.imageFile != null) {
      _currentImageFile = widget.imageFile;
    }
    if (widget.imageBytes != null) {
      _currentImageBytes = widget.imageBytes;
    }
    if (widget.existingItem != null &&
        widget.existingItem!['imagePath'] != null) {
      _existingImagePath = widget.existingItem!['imagePath'];
    }
  }

  void _initializeExistingItem() {
    final item = widget.existingItem!;
    _brandController.text = item['brand'] ?? '';
    _sizeController.text = item['size'] ?? '';
    _priceController.text = item['price'] ?? '';
    _tags.addAll(
      (item['tags'] ?? '').toString().split(',').where((t) => t.isNotEmpty),
    );
    _colors.addAll(
      (item['colors'] ?? '').toString().split(',').where((c) => c.isNotEmpty),
    );
    _selectedMainCategory = item['mainCategory'];
    _selectedSubCategory = item['category'];

    if (item['datePurchased'] != null && item['datePurchased'] != '') {
      _selectedDate = DateTime.tryParse(item['datePurchased']);
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Image Source',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.deepOrange),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.deepOrange,
                ),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_hasCurrentImage()) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Image'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageChanged = true;
          if (widget.isWeb) {
            // For web, we'll need to read the bytes
            image.readAsBytes().then((bytes) {
              setState(() {
                _currentImageBytes = bytes;
                _currentImageFile = null;
              });
            });
          } else {
            // For mobile, use the file
            _currentImageFile = File(image.path);
            _currentImageBytes = null;
          }
        });

        _showSuccessSnackbar('Image updated successfully!');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: ${e.toString()}');
    }
  }

  void _removeImage() {
    setState(() {
      _currentImageFile = null;
      _currentImageBytes = null;
      _existingImagePath = null;
      _imageChanged = true;
    });
    _showSuccessSnackbar('Image removed successfully!');
  }

  bool _hasCurrentImage() {
    return _currentImageFile != null ||
        _currentImageBytes != null ||
        (_existingImagePath != null && _existingImagePath!.isNotEmpty);
  }

  void _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.deepOrange),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _addColor(String color) {
    if (color.trim().isNotEmpty && !_colors.contains(color.trim())) {
      setState(() => _colors.add(color.trim()));
      _colorController.clear();
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() => _tags.add(tag.trim()));
      _tagsController.clear();
    }
  }

  Future<void> _saveItem() async {
    // ✅ Ensure pending inputs are captured
    if (_colorController.text.trim().isNotEmpty) {
      _addColor(_colorController.text);
    }
    if (_tagsController.text.trim().isNotEmpty) {
      _addTag(_tagsController.text);
    }

    // Check if we have an image (either new or existing)
    if (!_hasCurrentImage() && widget.existingItem == null) {
      _showErrorSnackbar("Please select an image first");
      return;
    }

    if (_brandController.text.trim().isEmpty) {
      _showErrorSnackbar("Brand name is required");
      return;
    }

    if (_selectedMainCategory == null) {
      _showErrorSnackbar("Please select a main category");
      return;
    }

    // Prepare item data
    final itemData = <String, dynamic>{
      'mainCategory': _selectedMainCategory ?? '',
      'category': _selectedSubCategory ?? '',
      'brand': _brandController.text.trim(),
      'size': _sizeController.text.trim(),
      'price': _priceController.text.trim(),
      'tags': _tags.join(','),
      'colors': _colors.join(','),
      'datePurchased': _selectedDate?.toIso8601String() ?? '',
    };

    // Handle image path
    if (_imageChanged) {
      if (_currentImageFile != null) {
        itemData['imagePath'] = _currentImageFile!.path;
      } else if (_currentImageBytes != null) {
        // For web, you might want to save bytes to a file or handle differently
        // This depends on your storage strategy for web
        itemData['imagePath'] = ''; // Handle web image storage as needed
      } else {
        itemData['imagePath'] = ''; // Image removed
      }
    } else if (widget.existingItem != null &&
        widget.existingItem!['imagePath'] != null) {
      // Keep existing image path if no changes made
      itemData['imagePath'] = widget.existingItem!['imagePath'];
    } else if (_currentImageFile != null) {
      itemData['imagePath'] = _currentImageFile!.path;
    } else {
      itemData['imagePath'] = '';
    }

    try {
      final db = DBHelper.instance;

      if (widget.existingItem != null && widget.existingItem!['id'] != null) {
        // Update existing item
        itemData['id'] = widget.existingItem!['id'];
        await db.updateItem(itemData);

        // ✅ Show snackbar BEFORE navigating
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Item updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }

        // ✅ Then navigate safely
        Navigator.pop(
          context,
          true,
        ); // Return to previous screen & trigger refresh
      } else {
        // Add new item
        final newId = await db.addItem(itemData);

        if (newId == -1) {
          _showErrorSnackbar("Failed to save item. Please try again.");
          return;
        }

        _showSuccessSnackbar("Item saved successfully!");

        // Wait a bit so user can see the success message
        await Future.delayed(const Duration(milliseconds: 800));

        // Then navigate to home page
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );

        // Just go back for new items
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error saving item: $e");
      _showErrorSnackbar("Error saving item: ${e.toString()}");
    }
  }

  void _showSizePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final sizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'];
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select Size',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...sizes
                    .map(
                      (size) => ListTile(
                        title: Text(size),
                        onTap: () {
                          setState(() => _sizeController.text = size);
                          Navigator.pop(context);
                        },
                        leading: const Icon(
                          Icons.straighten,
                          color: Colors.deepOrange,
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.existingItem != null ? 'Edit Item' : 'Add New Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildImagePreview(),
                          ),
                          // Edit overlay
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to change photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Form Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Field
                  _buildSectionTitle('Brand Information', Icons.business),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _brandController,
                    label: 'Brand Name',
                    hint: 'Enter brand name',
                    icon: Icons.local_offer,
                    required: true,
                  ),

                  const SizedBox(height: 32),

                  // Category Section
                  _buildSectionTitle('Category', Icons.category),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    value: _selectedMainCategory,
                    label: 'Main Category',
                    hint: 'Select main category',
                    icon: Icons.folder,
                    items:
                        _categoryMap.keys.map((mainCat) {
                          return DropdownMenuItem(
                            value: mainCat,
                            child: Text(mainCat),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMainCategory = value;
                        _selectedSubCategory = null;
                      });
                    },
                    required: true,
                  ),

                  if (_selectedMainCategory != null) ...[
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _selectedSubCategory,
                      label: 'Sub Category',
                      hint: 'Select sub category',
                      icon: Icons.folder_open,
                      items:
                          _categoryMap[_selectedMainCategory]!.map((sub) {
                            return DropdownMenuItem(
                              value: sub,
                              child: Text(sub),
                            );
                          }).toList(),
                      onChanged:
                          (value) =>
                              setState(() => _selectedSubCategory = value),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Details Section
                  _buildSectionTitle('Item Details', Icons.info_outline),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showSizePicker,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller: _sizeController,
                              label: 'Size',
                              hint: 'Select size',
                              icon: Icons.straighten,
                              suffixIcon: Icons.keyboard_arrow_down,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Price',
                          hint: '0.00',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          prefix: 'RM ',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date Purchased
                  _buildLabel('Date Purchased'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate == null
                                ? 'Select purchase date'
                                : DateFormat.yMMMd().format(_selectedDate!),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedDate == null
                                      ? Colors.grey[600]
                                      : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Colors Section
                  _buildSectionTitle('Colors', Icons.palette),
                  const SizedBox(height: 16),
                  if (_colors.isNotEmpty)
                    _buildChipDisplay('Colors', _colors, _colors.remove),
                  _buildAddField(
                    controller: _colorController,
                    label: 'Add Color',
                    hint: 'Enter color name',
                    icon: Icons.colorize,
                    onSubmitted: _addColor,
                  ),

                  const SizedBox(height: 32),

                  // Tags Section
                  _buildSectionTitle('Tags', Icons.local_offer),
                  const SizedBox(height: 16),
                  if (_tags.isNotEmpty)
                    _buildChipDisplay('Tags', _tags, _tags.remove),
                  _buildAddField(
                    controller: _tagsController,
                    label: 'Add Tag',
                    hint: 'Enter tag name',
                    icon: Icons.tag,
                    onSubmitted: _addTag,
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    // Priority: Current new image > existing image > placeholder
    if (_currentImageFile != null) {
      return Image.file(_currentImageFile!, fit: BoxFit.cover);
    } else if (_currentImageBytes != null) {
      return Image.memory(_currentImageBytes!, fit: BoxFit.cover);
    } else if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      return Image.file(File(_existingImagePath!), fit: BoxFit.cover);
    } else {
      return const Icon(Icons.add_a_photo, size: 64, color: Colors.grey);
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepOrange, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    String? prefix,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.deepOrange),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            prefixText: prefix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.deepOrange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAddField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.deepOrange),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add, color: Colors.deepOrange),
              onPressed: () => onSubmitted(controller.text),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
          ),
          onFieldSubmitted: onSubmitted,
        ),
      ],
    );
  }

  Widget _buildChipDisplay(
    String title,
    List<String> items,
    Function(String) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.deepOrange[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item,
                            style: TextStyle(
                              color: Colors.deepOrange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => onRemove(item)),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.deepOrange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
        children:
            required
                ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
                : null,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepOrange, Colors.orange],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    widget.existingItem != null ? 'Update Item' : 'Save Item',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
