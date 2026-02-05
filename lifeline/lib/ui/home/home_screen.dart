// lib/ui/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../emergency_flow/flow_controller.dart';
import '../emergency_flow/models/emergency_type.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final locationLabel = (ctrl.selectedLga ?? 'Ikeja') +
        ', ' +
        (ctrl.selectedState ?? 'Lagos');

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Welcome back',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 4),
              const Text('Stay Safe', style: AppTextStyles.h1),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/emergency/location'),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppDesignColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on,
                            color: AppDesignColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Location',
                                style: AppTextStyles.bodyMuted),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(locationLabel,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0x1A34C759),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.pill),
                                  ),
                                  child: const Text('? GPS',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppDesignColors.success)),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppDesignColors.gray400),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppDesignColors.danger, Color(0xFFFF4B42)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'PANIC MODE\nPress & hold for 3 seconds',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Emergency Services', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _services.map((s) {
                  return _ServiceCard(
                    title: s.title,
                    description: s.description,
                    color: s.color,
                    icon: s.icon,
                    onTap: () {
                      ctrl.pickType(s.type);
                      Navigator.pushNamed(context, '/emergency/results');
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  boxShadow: AppShadows.subtle,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: AppDesignColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your Trusted Circle',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/contacts/trusted'),
                      child: const Text('Manage'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text('Nearest Help Centers', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              ..._recentCenters.map((c) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['name']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(c['number']!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppDesignColors.gray500)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppDesignColors.gray400),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.info, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Safety Tip\nSave emergency numbers offline for quick access. Share your location with trusted contacts.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/emergency/location'),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppDesignColors.danger,
                shape: BoxShape.circle,
                boxShadow: AppShadows.soft,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final EmergencyType type;
  const _ServiceItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
  });
}

final List<_ServiceItem> _services = [
  _ServiceItem(
    title: 'Police',
    description: 'Report crimes & emergencies',
    icon: Icons.shield,
    color: AppDesignColors.primary,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'police'),
  ),
  _ServiceItem(
    title: 'Fire Service',
    description: 'Fire & rescue emergencies',
    icon: Icons.local_fire_department,
    color: AppDesignColors.danger,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'fire'),
  ),
  _ServiceItem(
    title: 'Hospital',
    description: 'Medical emergencies',
    icon: Icons.favorite,
    color: AppDesignColors.success,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'medical'),
  ),
  _ServiceItem(
    title: 'FRSC',
    description: 'Road accidents & safety',
    icon: Icons.directions_car,
    color: AppDesignColors.warning,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'road'),
  ),
  _ServiceItem(
    title: 'Amotekun',
    description: 'Regional security corps',
    icon: Icons.shield_rounded,
    color: AppDesignColors.amotekun,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'amotekun'),
  ),
  _ServiceItem(
    title: 'Mental Health',
    description: 'Psychological support',
    icon: Icons.psychology,
    color: AppDesignColors.mental,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'mental_health'),
  ),
];

final List<Map<String, String>> _recentCenters = [
  {'name': 'Lagos State Police Command', 'number': '112'},
  {'name': 'Lagos Fire Service', 'number': '112'},
  {'name': 'General Hospital Ikeja', 'number': '+234 803 XXX XXXX'},
];

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: AppDesignColors.gray500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
