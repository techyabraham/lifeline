// lib/ui/emergency_flow/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../widgets/common_widgets.dart';

class EmergencyHomeScreen extends StatelessWidget {
  const EmergencyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LifeLine')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 6),
              BigActionButton(
                label: 'I NEED HELP NOW',
                subtitle: 'Detect location and select emergency type',
                icon: Icons.warning_amber_rounded,
                color: AppColors.brandRed,
                onTap: () =>
                    Navigator.pushNamed(context, '/emergency/location'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _smallCard(
                        context, Icons.history, 'Recent Calls', '/recent'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        _smallCard(context, Icons.star, 'Saved', '/favorites'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.brandBlue,
                    child: Icon(Icons.group, color: Colors.white),
                  ),
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
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) =>
      InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.ink),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      );
}
