import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileScreen extends StatefulWidget {
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
      appBar: AppBar(title: Text('Profile & Settings')),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: darkMode,
            onChanged: (val) => setState(() => darkMode = val),
          ),
          ListTile(
            title: Text('Language'),
            subtitle: Text(language),
            onTap: () async {
              final selected = await showDialog<String>(
                  context: context,
                  builder: (_) => SimpleDialog(
                        title: Text('Select Language'),
                        children: ['English', 'Pidgin', 'Hausa', 'Yoruba', 'Igbo']
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
            title: Text('Saved Locations'),
            onTap: () {}, // implement saved locations
          ),
          SizedBox(height: 12),
          Text('App Info: Version 1.0.0'),
        ],
      ),
    );
  }
}
