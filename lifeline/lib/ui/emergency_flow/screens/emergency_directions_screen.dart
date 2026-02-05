// lib/ui/emergency_flow/screens/directions_screen.dart
import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../models/facility.dart';

class EmergencyDirectionsScreen extends StatelessWidget {
  const EmergencyDirectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final facility = args is Facility ? args : null;
    final name = facility?.name ?? 'Nearest Facility';
    final distance = facility != null
        ? '${facility.distanceKm.toStringAsFixed(1)} km'
        : '—';
    final etaMinutes = facility != null ? (facility.distanceKm / 30 * 60).round() : null;

    return Scaffold(
      backgroundColor: AppDesignColors.gray50,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: BoxDecoration(
              gradient: AppGradients.service(AppDesignColors.primary),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Directions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: const Color(0xFFFFC1C7)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            color: AppDesignColors.danger),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'If this is life-threatening, call the facility first to alert them before traveling.',
                            style: TextStyle(fontSize: 12, color: AppDesignColors.gray700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.navigation,
                                size: 16, color: AppDesignColors.gray500),
                            const SizedBox(width: 6),
                            Text(distance, style: AppTextStyles.body),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time,
                                size: 16, color: AppDesignColors.gray500),
                            const SizedBox(width: 6),
                            Text(
                              etaMinutes != null ? '$etaMinutes min' : '—',
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/emergency/calling',
                                arguments: {
                                  'providerName': name,
                                  'phone': facility?.phone ?? '',
                                },
                              );
                            },
                            icon: const Icon(Icons.call),
                            label: Text('Call $name'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppDesignColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadii.md),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.08,
                            child: CustomPaint(
                              painter: _GridPainter(),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppDesignColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.place, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Open in Navigation App', style: AppTextStyles.body),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _NavAppCard(
                          title: 'Google Maps',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NavAppCard(
                          title: 'Waze',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NavAppCard(
                          title: 'Apple',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF111827), Color(0xFF374151)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppDesignColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                          child: const Text('Call 112'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppDesignColors.gray700,
                            side: const BorderSide(color: AppDesignColors.gray200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                          child: const Text('Go Back'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavAppCard extends StatelessWidget {
  final String title;
  final LinearGradient gradient;

  const _NavAppCard({required this.title, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.navigation, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppDesignColors.gray400
      ..strokeWidth = 1;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
