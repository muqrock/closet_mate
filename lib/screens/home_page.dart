import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ProfileTab(),
    const Center(child: Text('Wardrobe Tab')),
    const Center(child: Text('Planner Tab')),
    const Center(child: Text('Settings Tab')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () => _showAddOptionsDialog(context),
                backgroundColor: Colors.deepOrange,
                child: const Icon(Icons.add, size: 30),
                shape: const CircleBorder(),
                elevation: 6,
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'What would you like to do?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.checkroom),
                label: const Text('Create Outfit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String currentView = 'main';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFFFF914D),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/75.jpg',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Muqri Shaberi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                '@muqrock',
                style: TextStyle(fontSize: 14, color: Colors.white70),
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildViewContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatButton(String type) {
    String label = type == 'items' ? 'Items' : 'Outfits';
    return GestureDetector(
      onTap: () {
        setState(() {
          if (currentView == type) {
            currentView = 'main';
          } else {
            currentView = type;
          }
        });
      },
      child: Column(
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
      ),
    );
  }

  Widget _buildViewContent() {
    if (currentView == 'items') {
      return _buildDummyGrid('Item');
    } else if (currentView == 'outfits') {
      return _buildDummyGrid('Outfit');
    } else {
      return const Center(
        child: Text(
          'Scroll down for more features...',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildDummyGrid(String label) {
    return GridView.builder(
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                label == 'Item' ? Icons.checkroom : Icons.style,
                size: 40,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 10),
              Text(
                '$label ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
