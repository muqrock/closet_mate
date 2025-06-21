import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNightMode = false;
  bool notificationsOn = true;
  bool isMalay = false;

  bool showPersonalization = false;
  bool showNotifications = false;
  bool showLanguage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // 🔙 Back Button and Title
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed:
                      () => Navigator.pushReplacementNamed(context, '/home'),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 👤 Edit Profile
            _buildSettingTile(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),

            const Divider(height: 20),

            // 🎨 Personalization
            _buildExpandableTile(
              icon: Icons.palette_outlined,
              label: 'Personalization',
              expanded: showPersonalization,
              onTap:
                  () => setState(
                    () => showPersonalization = !showPersonalization,
                  ),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Night Mode'),
                  value: isNightMode,
                  onChanged: (val) {
                    setState(() => isNightMode = val);
                  },
                ),
              ],
            ),

            const Divider(height: 20),

            // 🔔 Notifications
            _buildExpandableTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              expanded: showNotifications,
              onTap:
                  () => setState(() => showNotifications = !showNotifications),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Notifications'),
                  value: notificationsOn,
                  onChanged: (val) {
                    setState(() => notificationsOn = val);
                  },
                ),
              ],
            ),

            const Divider(height: 20),

            // 🌐 Language
            _buildExpandableTile(
              icon: Icons.language,
              label: 'Language',
              expanded: showLanguage,
              onTap: () => setState(() => showLanguage = !showLanguage),
              children: [
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('English'),
                  value: false,
                  groupValue: isMalay,
                  onChanged: (val) {
                    setState(() => isMalay = val!);
                  },
                ),
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Malay'),
                  value: true,
                  groupValue: isMalay,
                  onChanged: (val) {
                    setState(() => isMalay = val!);
                  },
                ),
              ],
            ),

            const Divider(height: 20),

            // 🚪 Logout
            _buildSettingTile(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildExpandableTile({
    required IconData icon,
    required String label,
    required bool expanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.deepOrange),
          title: Text(label),
          trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          onTap: onTap,
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Column(children: children),
          ),
      ],
    );
  }
}
