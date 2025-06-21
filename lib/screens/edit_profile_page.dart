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
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedBirthday;

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _isCurrentPasswordValid = false;

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

  Future<void> _validateCurrentPassword(String inputPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: inputPassword,
    );
    try {
      await user.reauthenticateWithCredential(cred);
      setState(() => _isCurrentPasswordValid = true);
    } catch (_) {
      setState(() => _isCurrentPasswordValid = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final bool isChangingPassword =
        _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty;

    if (isChangingPassword && !_isCurrentPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect current password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'fullName': _fullNameController.text.trim(),
            'username': _usernameController.text.trim(),
            'email':
                _emailController.text.trim(), // still stored but uneditable
            'gender': _selectedGender,
            'birthday':
                _selectedBirthday != null
                    ? Timestamp.fromDate(_selectedBirthday!)
                    : null,
          });

      if (isChangingPassword) {
        await user.updatePassword(_newPasswordController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated. Please log in again.'),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
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
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/settings');
          },
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
                inputType: TextInputType.emailAddress,
                readOnly: true,
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

              // 🔒 Current Password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrentPassword,
                onChanged: _validateCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currentPasswordController.text.isNotEmpty)
                        Icon(
                          _isCurrentPasswordValid
                              ? Icons.check_circle
                              : Icons.error,
                          color:
                              _isCurrentPasswordValid
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      IconButton(
                        icon: Icon(
                          _showCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(
                              () =>
                                  _showCurrentPassword = !_showCurrentPassword,
                            ),
                      ),
                    ],
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 🔐 New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_newPasswordController.text.isNotEmpty)
                        const Icon(Icons.check_circle, color: Colors.green),
                      IconButton(
                        icon: Icon(
                          _showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(
                              () => _showNewPassword = !_showNewPassword,
                            ),
                      ),
                    ],
                  ),
                  border: const OutlineInputBorder(),
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
    String label, {
    TextInputType inputType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
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
