// lib/ui/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Welcome back',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'Stay Safe',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/emergency/location'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on,
                            color: AppColors.brandBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Location',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.muted)),
                            Text(locationLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text('Emergency Services',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
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
              const Text('Nearest Help Centers',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ..._recentCenters.map((c) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                                      fontSize: 12, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.muted),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandBlue, AppColors.brandBlueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
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
              const SizedBox(height: 80),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/emergency/location'),
            backgroundColor: AppColors.brandRed,
            child: const Icon(Icons.warning_amber_rounded),
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
    color: AppColors.brandBlue,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'police'),
  ),
  _ServiceItem(
    title: 'Fire Service',
    description: 'Fire & rescue emergencies',
    icon: Icons.local_fire_department,
    color: AppColors.brandRed,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'fire'),
  ),
  _ServiceItem(
    title: 'Hospital',
    description: 'Medical emergencies',
    icon: Icons.favorite,
    color: AppColors.brandGreen,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'medical'),
  ),
  _ServiceItem(
    title: 'FRSC',
    description: 'Road accidents & safety',
    icon: Icons.directions_car,
    color: AppColors.brandOrange,
    type: defaultEmergencyTypes.firstWhere((t) => t.id == 'road'),
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
