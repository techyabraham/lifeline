// lib/ui/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../blocs/theme/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandBlue, AppColors.brandBlueDark],
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: Text('JD',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('John Doe',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('john.doe@email.com',
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Account',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          _SettingsCard(
            items: [
              _SettingsItem(
                  icon: Icons.person, label: 'Edit Profile', value: 'John Doe'),
              _SettingsItem(
                  icon: Icons.location_on,
                  label: 'Saved Locations',
                  value: '3 locations'),
              _SettingsItem(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  value: 'Enabled'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Preferences',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          _SettingsCard(
            items: [
              _SettingsItem(
                  icon: Icons.language, label: 'Language', value: 'English'),
              _SettingsItem(
                icon: Icons.dark_mode,
                label: 'Dark Mode',
                value: 'toggle',
                onTap: () => context.read<ThemeBloc>().add(ToggleTheme()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('About',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          _SettingsCard(
            items: [
              _SettingsItem(icon: Icons.shield, label: 'Privacy Policy'),
              _SettingsItem(icon: Icons.favorite, label: 'Support LifeLine'),
              _SettingsItem(icon: Icons.info, label: 'App Version', value: 'v1.0.0'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandBlue, AppColors.brandBlueDark],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield, color: Colors.white),
                const SizedBox(height: 8),
                const Text('Emergency Helpline',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                  'For immediate assistance, dial 112 from anywhere in Nigeria',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Call 112 Now'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Log Out',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: items.map((item) {
          final isToggle = item.value == 'toggle';
          return InkWell(
            onTap: isToggle ? item.onTap : null,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: items.last == item
                        ? Colors.transparent
                        : AppColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: AppColors.ink, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  if (isToggle)
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        return Switch(
                          value: state.isDarkMode,
                          onChanged: (_) =>
                              context.read<ThemeBloc>().add(ToggleTheme()),
                        );
                      },
                    )
                  else if (item.value != null)
                    Text(item.value!,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  const _SettingsItem(
      {required this.icon, required this.label, this.value, this.onTap});
}
