import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _wardrobeTabIndex = 0; // For Items/Outfits sub-tabs

  List<Widget> get _pages => [
    const ProfileTab(),
    const WardrobeTab(),
    const PlannerTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton:
          _currentIndex ==
                  0 // Show on Profile tab
              ? FloatingActionButton(
                onPressed: () => _showAddOptionsDialog(context),
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black, size: 36),
              )
              : null,
      body: SafeArea(child: _pages[_currentIndex]),
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 20,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Add Item Page
                  },
                  child: const Text('Add items'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Create Outfit Page
                  },
                  child: const Text('Create outfits'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addNewItem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add New Item', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () {
                    /* TODO */
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    /* TODO */
                  },
                ),
              ],
            ),
          ),
    );
  }
}

// Tab Widgets
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.indigo,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'profile-avatar',
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/women/65.jpg',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'muqri shaberi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  '@muqrock',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildProfileOption('Edit Profile', Icons.edit),
              _buildProfileOption('My Statistics', Icons.analytics),
              _buildProfileOption('Preferences', Icons.settings),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        /* TODO */
      },
    );
  }
}

class WardrobeTab extends StatefulWidget {
  const WardrobeTab({super.key});

  @override
  State<WardrobeTab> createState() => _WardrobeTabState();
}

class _WardrobeTabState extends State<WardrobeTab> {
  int _activeSubTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => setState(() => _activeSubTab = 0),
                child: _buildTabItem('Items (0)', _activeSubTab == 0),
              ),
              GestureDetector(
                onTap: () => setState(() => _activeSubTab = 1),
                child: _buildTabItem('Outfits (0)', _activeSubTab == 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildViewContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.orange : Colors.white,
        ),
      ),
    );
  }

  Widget _buildItemsView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 0,
      itemBuilder: (context, index) => const SizedBox(),
    );
  }

  Widget _buildOutfitsView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Create your first outfit',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Planner Tab',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Settings Tab',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  // Helper widget to build each settings option ListTile
  Widget _buildSettingsOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: Colors.black,
            size: 28,
          ), // Black icons, slightly larger
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black, // Black text
              fontSize: 17, // Slightly larger font for list titles
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.black,
          ), // Black right arrow
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 5.0,
          ), // Adjust padding
        ),
        Divider(
          height: 1,
          thickness: 0.8,
          indent: 20,
          endIndent: 20,
          color: Colors.grey[300],
        ), // Subtle divider
      ],
    );
  }
}
