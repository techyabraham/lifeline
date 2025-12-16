// lib/ui/home/redesigned_home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RedesignedHome extends StatelessWidget {
  const RedesignedHome({super.key});

  void _startEmergencyFlow(BuildContext context) {
    // 1 tap - start emergency -> triggers location detection screen
    Navigator.pushNamed(context, '/location');
  }

  @override
  Widget build(BuildContext context) {
    // High-contrast brand colors
    const primary = Color(0xFF0047AB); // trust blue
    const accent = Color(0xFFFF3B30); // emergency red

    // Use large safe area padding so buttons are above nav gestures
    final bottomPad = MediaQuery.of(context).viewPadding.bottom + 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeLine'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Primary Action Card
              Hero(
                tag: 'big-action',
                child: GestureDetector(
                  onTap: () => _startEmergencyFlow(context),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accent, Color(0xFFB91C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            size: 54, color: Colors.white),
                        SizedBox(height: 12),
                        Text(
                          'I NEED HELP NOW',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tap to find nearest emergency services — 3 taps to call',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quick access cards
              Row(
                children: [
                  Expanded(
                    child: _QuickCard(
                      color: primary.withOpacity(0.08),
                      icon: Icons.history,
                      title: 'Recent Calls',
                      subtitle: 'Quick redial',
                      onTap: () => Navigator.pushNamed(context, '/recent'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickCard(
                      color: Colors.amber.withOpacity(0.08),
                      icon: Icons.star_border,
                      title: 'Saved Contacts',
                      subtitle: 'Favorites',
                      onTap: () => Navigator.pushNamed(context, '/favorites'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // My Emergency Contacts card (strategic integration point)
              _EmergencyContactsCard(
                  onTap: () => Navigator.pushNamed(context, '/contacts')),

              const Spacer(),

              // Footer quick tips
              Column(
                children: [
                  const Text(
                    'Tip: Turn on location for faster results. No signup required.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  SizedBox(height: bottomPad),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
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
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyContactsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmergencyContactsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Placeholder; hook with local Hive for saved contacts count
    final savedCount = 3;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF0047AB),
          child: Icon(Icons.group, color: Colors.white),
        ),
        title: const Text('My Emergency Contacts'),
        subtitle: Text('$savedCount contacts saved'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
