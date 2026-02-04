// lib/ui/contacts/contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/call_service.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('My Emergency Contacts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable:
                Hive.box('contacts_cache').listenable(keys: ['contacts']),
            builder: (context, Box box, _) {
              final raw = box.get('contacts', defaultValue: <dynamic>[]) as List;
              final contacts = raw
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF9A8D4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Color(0xFFEC4899)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your Trusted Circle (${contacts.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  title: 'Alert All',
                  icon: Icons.notifications_active,
                  color: AppColors.brandRed,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  title: 'Add New',
                  icon: Icons.person_add,
                  color: AppColors.brandBlue,
                  onTap: () => Navigator.pushNamed(context, '/contacts/add'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box('contacts_cache').listenable(keys: ['contacts']),
              builder: (context, Box box, _) {
                final contacts = List<Map<String, dynamic>>.from(
                  (box.get('contacts', defaultValue: <dynamic>[]) as List)
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList(),
                );
                if (contacts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No contacts yet.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final c = contacts[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE7F3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.people,
                                    color: Color(0xFFEC4899)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${c['name']}${c['priority'] == true ? ' ⭐' : ''}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (c['relationship'] ?? '') as String,
                                      style: const TextStyle(
                                          fontSize: 11, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                              onPressed: () => _call(context, c['phone'] as String),
                                  icon: const Icon(Icons.call, size: 18),
                                  label: const Text('Call'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brandGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _sms(c['phone'] as String),
                                  icon: const Icon(Icons.send, size: 18),
                                  label: const Text('SMS'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brandBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _call(BuildContext context, String phone) async {
    await CallService.call(context, phone);
  }

  Future<void> _sms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    await launchUrl(uri);
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
