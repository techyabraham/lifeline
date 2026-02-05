// lib/ui/emergency_flow/screens/emergency_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system.dart';
import '../flow_controller.dart';
import '../models/emergency_type.dart';

class EmergencySelectionScreen extends StatelessWidget {
  const EmergencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final lga = ctrl.selectedLga ?? 'Ikeja, Lagos';

    return Scaffold(
      backgroundColor: AppDesignColors.gray50,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
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
                const Text('What Emergency?', style: AppTextStyles.h2),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppDesignColors.primary),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppDesignColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    lga,
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
                          childAspectRatio: 0.95,
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
                            fullWidth: true,
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
  final bool fullWidth;

  const _EmergencyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
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
            crossAxisAlignment:
                fullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: fullWidth ? TextAlign.center : TextAlign.left,
                style: const TextStyle(
                  color: AppDesignColors.gray900,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: fullWidth ? TextAlign.center : TextAlign.left,
                style: const TextStyle(
                  color: AppDesignColors.gray500,
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
