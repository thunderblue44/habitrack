import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../themes/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // User profile section
          if (user != null) ...[
            _buildSectionHeader(context, 'Profile'),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(user.username),
              subtitle: Text(user.email),
            ),
            const Divider(),
          ],

          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(themeProvider.isDarkMode ? 'On' : 'Off'),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
          ),
          const Divider(),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Will implement later
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),
          const Divider(),

          // About section
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About HabiTrack'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Will implement later
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),
          const Divider(),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () async {
                // Show confirmation dialog
                final shouldLogout = await _showLogoutConfirmationDialog(
                  context,
                );
                if (shouldLogout && context.mounted) {
                  await authProvider.logout();
                  // Navigate to login screen and remove all previous routes
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'HabiTrack',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'HabiTrack helps you build and track habits effectively. '
          'Create both positive habits to build or negative habits to break, '
          'track your progress over time, and stay motivated with insights and stats.',
        ),
        const SizedBox(height: 16),
        const Text('© 2025 HabiTrack. All rights reserved.'),
      ],
    );
  }
}
