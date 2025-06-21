import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedBirthday;

  bool _isLoading = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      if (data != null) {
        _fullNameController.text = data['fullName'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
        _selectedGender = data['gender'];
        if (data['birthday'] != null) {
          _selectedBirthday = (data['birthday'] as Timestamp).toDate();
        }
        setState(() {});
      }
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthday = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'fullName': _fullNameController.text.trim(),
              'username': _usernameController.text.trim(),
              'email': _emailController.text.trim(),
              'gender': _selectedGender,
              'birthday':
                  _selectedBirthday != null
                      ? Timestamp.fromDate(_selectedBirthday!)
                      : null,
            });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.orangeAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 30),

              _buildTextField(_fullNameController, 'Full Name'),
              _buildTextField(_usernameController, 'Username'),
              _buildTextField(
                _emailController,
                'Email',
                TextInputType.emailAddress,
              ),

              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (val) => setState(() => _selectedGender = val),
                items:
                    _genders
                        .map(
                          (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.people_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                readOnly: true,
                onTap: () => _selectBirthday(context),
                controller: TextEditingController(
                  text:
                      _selectedBirthday == null
                          ? ''
                          : '${_selectedBirthday!.month}/${_selectedBirthday!.day}/${_selectedBirthday!.year}',
                ),
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator(color: Colors.deepOrange)
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType inputType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.text_fields),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
