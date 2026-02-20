import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (val) {
              // Usually handled by a ThemeNotifier, placeholder for now
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          ListTile(
             title: const Text('Storage Location'),
             subtitle: const Text('Downloads are saved to your app directory'),
             leading: const Icon(Icons.folder),
             onTap: () {},
          ),
          ListTile(
             title: const Text('Clear Search History'),
             leading: const Icon(Icons.history),
             onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search history cleared')));
             },
          ),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('MediaSaver Pro v1.0.0'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'MediaSaver Pro',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 MediaSaver Pro. All rights reserved.',
              );
            },
          ),
        ],
      ),
    );
  }
}
