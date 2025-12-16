// lib/ui/emergency_flow/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class EmergencyHomeScreen extends StatelessWidget {
  const EmergencyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF3B30);
    return Scaffold(
      appBar: AppBar(title: const Text('LifeLine')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              const SizedBox(height: 10),
              BigActionButton(
                label: 'I NEED HELP NOW',
                subtitle:
                    'Tap to detect location and select emergency type (3 taps)',
                icon: Icons.warning,
                color: accent,
                onTap: () =>
                    Navigator.pushNamed(context, '/emergency/location'),
              ),
              const SizedBox(height: 18),
              // small quick actions
              Row(
                children: [
                  Expanded(
                      child: _smallCard(
                          context, Icons.history, 'Recent Calls', '/recent')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _smallCard(
                          context, Icons.star, 'Saved', '/favorites')),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.group)),
                  title: const Text('My Emergency Contacts'),
                  subtitle: const Text('3 contacts saved'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/contacts'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallCard(
          BuildContext context, IconData icon, String title, String route) =>
      InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [Icon(icon), const SizedBox(height: 8), Text(title)],
          ),
        ),
      );
}
