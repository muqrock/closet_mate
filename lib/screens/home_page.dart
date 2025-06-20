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
  // int _wardrobeTabIndex = 0; // This variable is not used in HomePage anymore, only in WardrobeTab's state

  List<Widget> get _pages => [
    const ProfileTab(),
    const WardrobeTab(),
    const PlannerTab(),
    SettingsTab(
      onBack: () => setState(() => _currentIndex = 0),
    ), // 👈 go to Profile tab
  ];

  // Function to show the custom action dialog (for Add Item/Outfit)
  void _showAddActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20.0,
            ), // Rounded corners for the dialog
          ),
          elevation: 0,
          backgroundColor: Colors.transparent, // Make background transparent
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content tightly
              children: [
                // "Add items" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      // TODO: Navigate to Add Item screen
                      print('Add Items Clicked!');
                      // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.deepOrange, // Your app's primary color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Add items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15), // Spacing between buttons
                // "Create outfits" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      // TODO: Navigate to Create Outfits screen
                      print('Create Outfits Clicked!');
                      // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CreateOutfitScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors
                              .grey
                              .shade200, // Lighter background for secondary action
                      foregroundColor:
                          Colors.deepOrange, // Text color matches app theme
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.deepOrange.shade200,
                          width: 1.5,
                        ), // Subtle border
                      ),
                      elevation: 1,
                    ),
                    child: const Text(
                      'Create outfits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Consistent light background
      extendBody:
          true, // Allows BottomNavigationBar to be transparent and float
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Notch for the FAB
        notchMargin: 8.0, // Space between FAB and AppBar
        color: Colors.white, // Background color of the bottom bar
        elevation: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavBarItem(0, Icons.person, 'Profile'),
            _buildNavBarItem(1, MdiIcons.wardrobe, 'Wardrobe'),
            const SizedBox(width: 48), // The space for the FAB
            _buildNavBarItem(2, Icons.calendar_today, 'Planner'),
            _buildNavBarItem(3, Icons.settings, 'Settings'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          _currentIndex ==
                  1 // Show FAB only on Wardrobe tab (index 1)
              ? FloatingActionButton(
                onPressed:
                    () => _showAddActionDialog(context), // Call the new dialog
                backgroundColor: Colors.deepOrange, // Your app's primary color
                foregroundColor: Colors.white,
                shape: const CircleBorder(), // Ensure it's a perfect circle
                elevation: 8,
                child: const Icon(Icons.add, size: 36),
              )
              : null,
      body: SafeArea(child: _pages[_currentIndex]),
    );
  }

  // Helper method to build BottomNavigationBar items
  Widget _buildNavBarItem(int index, IconData icon, String label) {
    return Expanded(
      child: Material(
        color: Colors.transparent, // Make the Material background transparent
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color:
                      _currentIndex == index
                          ? Colors.deepOrange
                          : Colors.grey[600],
                  size: 26,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        _currentIndex == index
                            ? Colors.deepOrange
                            : Colors.grey[600],
                    fontSize: 12,
                    fontWeight:
                        _currentIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tab Widgets
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _fullName = 'Loading...';
  String _username = 'Loading...';
  String _profileImageUrl =
      'https://via.placeholder.com/150'; // Default placeholder

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // You'd typically fetch from Firestore for full name and username
      // For now, let's use a placeholder or email if no Firestore data is set up yet
      // final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _fullName =
            user.email ?? 'No Name'; // Placeholder, replace with Firestore data
        _username = user.email?.split('@')[0] ?? 'No Username'; // Placeholder
        // You can set a default image or fetch from user profile/Firestore
        // _profileImageUrl = userData.data()?['profileImageUrl'] ?? 'https://randomuser.me/api/portraits/women/65.jpg';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.deepOrange, // Changed to deepOrange for consistency
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30), // Rounded bottom corners
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
          ), // Adjusted padding
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'profile-avatar',
                  child: CircleAvatar(
                    radius: 50, // Slightly larger avatar
                    backgroundColor: Colors.white, // White border
                    child: CircleAvatar(
                      radius: 47,
                      backgroundImage: NetworkImage(_profileImageUrl),
                    ),
                  ),
                ),
                const SizedBox(height: 12), // Increased spacing
                Text(
                  _fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Larger font size
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$_username',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfileStat(
                      'Items',
                      '0',
                    ), // Replace with actual counts
                    const SizedBox(width: 30),
                    _buildProfileStat(
                      'Outfits',
                      '0',
                    ), // Replace with actual counts
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            children: [
              // You can add profile options here, but consider the Figma shows just name/username/counts
              // If you still want these, they could be here:
              // _buildProfileOption('Edit Profile', Icons.edit),
              // _buildProfileOption('My Statistics', Icons.analytics),
              // _buildProfileOption('Preferences', Icons.settings),
              // Add a logout button to ProfileTab for easy access (though it's also in Settings)
              // ListTile(
              //   leading: Icon(Icons.logout, color: Colors.deepOrange),
              //   title: const Text('Logout'),
              //   onTap: () async {
              //     await FirebaseAuth.instance.signOut();
              //     Navigator.pushReplacementNamed(context, '/login');
              //   },
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}

class WardrobeTab extends StatefulWidget {
  const WardrobeTab({super.key});

  @override
  State<WardrobeTab> createState() => _WardrobeTabState();
}

class _WardrobeTabState extends State<WardrobeTab> {
  int _activeSubTab = 0; // 0 for Items, 1 for Outfits

  // Dummy data for demonstration. Replace with actual data from Firestore.
  final List<String> _items = []; // Your actual list of items
  final List<String> _outfits = []; // Your actual list of outfits

  @override
  Widget build(BuildContext context) {
    bool showAddItemCard =
        (_activeSubTab == 0 && _items.isEmpty) ||
        (_activeSubTab == 1 && _outfits.isEmpty);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.deepOrange, // Matches the new theme
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          height: 60, // Slightly taller for better appearance
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeSubTab = 0),
                  child: _buildTabItem(
                    'Items (0)',
                    _activeSubTab == 0,
                  ), // Update count dynamically
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeSubTab = 1),
                  child: _buildTabItem(
                    'Outfits (0)',
                    _activeSubTab == 1,
                  ), // Update count dynamically
                ),
              ),
            ],
          ),
        ),
        // Add your item now card conditional display
        if (showAddItemCard) // Show only if the current sub-tab is empty
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () {
                // Trigger the main FAB action when this card is tapped
                // This requires a bit of a workaround since FAB is in HomePage
                // For simplicity, we can just print for now or navigate directly to add item
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tap the + button to add items/outfits!'),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color:
                      Colors
                          .grey
                          .shade200, // Light grey background for the card
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 50, color: Colors.grey.shade600),
                    const SizedBox(height: 10),
                    Text(
                      'add your item now',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: _activeSubTab == 0 ? _buildItemsView() : _buildOutfitsView(),
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, bool isActive) {
    return Container(
      alignment: Alignment.center, // Center the text within the container
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16, // Slightly larger font size
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.deepOrange : Colors.white,
        ),
      ),
    );
  }

  Widget _buildItemsView() {
    // Show grid if items exist, otherwise the card takes its place via conditional rendering
    if (_items.isEmpty) {
      return const SizedBox.shrink(); // This will make the Expanded widget empty if the card is shown
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _items.length, // Use actual item count
      itemBuilder: (context, index) {
        // Replace with your actual ItemCard widget
        return Card(
          color: Colors.orange.shade100,
          child: Center(child: Text('Item ${_items[index]}')),
        );
      },
    );
  }

  Widget _buildOutfitsView() {
    // Show grid if outfits exist, otherwise the card takes its place via conditional rendering
    if (_outfits.isEmpty) {
      return const SizedBox.shrink(); // This will make the Expanded widget empty if the card is shown
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _outfits.length, // Use actual outfit count
      itemBuilder: (context, index) {
        // Replace with your actual OutfitCard widget
        return Card(
          color: Colors.orange.shade200,
          child: Center(child: Text('Outfit ${_outfits[index]}')),
        );
      },
    );
  }
}

class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Planner Tab Content',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final VoidCallback onBack;

  const SettingsTab({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background as per image
      appBar: AppBar(
        backgroundColor: Colors.white, // White app bar background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), // Black back arrow
          onPressed: onBack,
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black, // Black title text
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildSettingsOption(
            context,
            'Edit profile',
            Icons
                .person_outline, // Using person_outline to match profile icon in image
            () {
              // TODO: Navigate to Edit Profile Page
              print('Edit profile tapped');
              // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
            },
          ),
          _buildSettingsOption(
            context,
            'Personalization',
            Icons.brush_outlined, // Using brush_outlined for personalization
            () {
              // TODO: Navigate to Personalization Page
              print('Personalization tapped');
            },
          ),
          _buildSettingsOption(
            context,
            'Notifications',
            Icons.notifications_outlined, // Notifications icon
            () {
              // TODO: Navigate to Notifications Settings Page
              print('Notifications tapped');
            },
          ),
          _buildSettingsOption(
            context,
            'Language',
            Icons.language_outlined, // Language icon
            () {
              // TODO: Navigate to Language Settings Page
              print('Language tapped');
            },
          ),
          _buildSettingsOption(
            context,
            'Log out',
            Icons.logout, // Logout icon
            () async {
              try {
                await FirebaseAuth.instance.signOut();
                // After signing out, navigate back to the login page and remove all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
                print('User logged out successfully.');
              } catch (e) {
                print('Error during logout: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error logging out: $e')),
                );
              }
            },
          ),
        ],
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
