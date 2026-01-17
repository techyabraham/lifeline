import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool darkMode = false;
  String language = 'English';

  @override
  void initState() {
    super.initState();
    // Load saved preferences from Hive or SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.brandBlue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Guest User'),
              subtitle: const Text('Tap to set up your profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: darkMode,
            onChanged: (val) => setState(() => darkMode = val),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(language),
            onTap: () async {
              final selected = await showDialog<String>(
                  context: context,
                  builder: (_) => SimpleDialog(
                        title: const Text('Select Language'),
                        children: [
                          'English',
                          'Pidgin',
                          'Hausa',
                          'Yoruba',
                          'Igbo'
                        ]
                            .map((lang) => SimpleDialogOption(
                                  child: Text(lang),
                                  onPressed: () => Navigator.pop(context, lang),
                                ))
                            .toList(),
                      ));
              if (selected != null) setState(() => language = selected);
            },
          ),
          ListTile(
            title: const Text('Saved Locations'),
            onTap: () {}, // implement saved locations
          ),
          const SizedBox(height: 12),
          const Text('App Info: Version 1.0.0',
              style: TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}
