// lib/ui/home/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF3B30);
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final safeBottom = (bottomPad < 12) ? 16.0 : bottomPad + 8.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeLine'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
            tooltip: 'Search contacts',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Hero CTA (I NEED HELP NOW)
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/emergency/location'),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [accent, Color(0xFFCC2B2B)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: accent.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.report, size: 46, color: Colors.white),
                      SizedBox(height: 10),
                      Text('I NEED HELP NOW',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('Tap to detect location and call nearest help',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Quick action cards
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/recent'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(children: const [
                          Icon(Icons.history, size: 30),
                          SizedBox(height: 8),
                          Text('Recent Calls',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/favorites'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(children: const [
                          Icon(Icons.star, size: 30, color: Colors.amber),
                          SizedBox(height: 8),
                          Text('Saved',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // My Emergency Contacts card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: () => Navigator.pushNamed(context, '/contacts'),
                  leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.group, color: Colors.blue)),
                  title: const Text('My Emergency Contacts'),
                  subtitle: const Text('3 contacts saved'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),

              const SizedBox(height: 12),

              // Quick tip / educational card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: const [
                      Icon(Icons.lightbulb, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              'Tip: In a medical emergency, stay calm and provide clear location details when calling.')),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Ad placeholder - keep bottom safe padding
              Padding(
                padding: EdgeInsets.only(bottom: safeBottom),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  alignment: Alignment.center,
                  // Replace this Container with your BannerAd widget
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('AdMob banner (bottom)'),
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating SOS button (always visible)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/emergency/location'),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.sos),
        label: const Text('SOS'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
