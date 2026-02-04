// lib/ui/emergency_flow/screens/emergency_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../flow_controller.dart';
import '../models/emergency_type.dart';

class EmergencySelectionScreen extends StatelessWidget {
  const EmergencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final lga = ctrl.selectedLga ?? 'Ikeja, Lagos';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 6),
                const Text('What Emergency?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.brandBlue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.brandBlue),
                  const SizedBox(width: 8),
                  Text(
                    lga,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Builder(builder: (context) {
                final personal = defaultEmergencyTypes
                    .where((t) => t.isPersonal)
                    .toList();
                final mainTypes = defaultEmergencyTypes
                    .where((t) => !t.isPersonal)
                    .toList();
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: mainTypes.length,
                        itemBuilder: (context, index) {
                          final t = mainTypes[index];
                          return _EmergencyCard(
                            title: t.title,
                            description: t.description,
                            icon: t.icon,
                            color: t.color,
                            onTap: () {
                              ctrl.pickType(t);
                              Navigator.pushNamed(
                                  context, '/emergency/results');
                            },
                          );
                        },
                      ),
                      if (personal.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _EmergencyCard(
                            title: personal.first.title,
                            description: personal.first.description,
                            icon: personal.first.icon,
                            color: personal.first.color,
                            onTap: () =>
                                Navigator.pushNamed(context, '/contacts'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 38),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
