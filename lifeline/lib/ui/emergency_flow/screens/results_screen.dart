// lib/ui/emergency_flow/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system.dart';
import '../flow_controller.dart';
import '../models/facility.dart';
import '../../../services/call_service.dart';
import '../../widgets/design_widgets.dart';

class EmergencyResultsScreen extends StatefulWidget {
  const EmergencyResultsScreen({super.key});
  @override
  State<EmergencyResultsScreen> createState() => _EmergencyResultsScreenState();
}

class _EmergencyResultsScreenState extends State<EmergencyResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFacilities());
  }

  Future<void> _loadFacilities() async {
    final ctrl = Provider.of<EmergencyFlowController>(context, listen: false);
    await ctrl.loadFacilities();
  }

  Future<void> _call(String phone) async {
    final ctrl = Provider.of<EmergencyFlowController>(context, listen: false);
    if (ctrl.notifyingContacts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifying your contacts...')),
      );
    }
    await CallService.call(context, phone);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final headerColor = ctrl.selectedType?.color ?? AppDesignColors.primary;
    final locationLabel =
        '${ctrl.selectedLga ?? 'Ikeja'}, ${ctrl.selectedState ?? 'Lagos'}';

    return Scaffold(
      backgroundColor: AppDesignColors.gray50,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: BoxDecoration(
              gradient: AppGradients.service(headerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Nearest Facilities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      locationLabel,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!ctrl.notifyingContacts)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(color: AppDesignColors.gray200),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Notify family?',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Alert emergency contacts with your location',
                                  style: TextStyle(
                                      color: AppDesignColors.gray500, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => ctrl.setNotifyContacts(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppDesignColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadii.md),
                              ),
                            ),
                            child: const Text(
                              'Yes, Notify',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (ctrl.notifyingContacts) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x1A34C759),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(color: const Color(0x3348D16A)),
                      ),
                      child: const Text(
                        'Family notified ?',
                        style: TextStyle(
                            color: AppDesignColors.success,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (ctrl.loading)
                    const LinearProgressIndicator(minHeight: 3),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ctrl.facilities.isEmpty
                        ? const Center(child: Text('No facilities found.'))
                        : ListView.builder(
                            itemCount: ctrl.facilities.length,
                            itemBuilder: (context, i) {
                              final f = ctrl.facilities[i];
                              return _FacilityCard(
                                facility: f,
                                rank: i + 1,
                                onCall: () => _call(f.phone),
                                onDirections: () => Navigator.pushNamed(
                                  context,
                                  '/emergency/directions',
                                  arguments: f,
                                ),
                              );
                            },
                          ),
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

class _FacilityCard extends StatelessWidget {
  final Facility facility;
  final int rank;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _FacilityCard({
    required this.facility,
    required this.rank,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final etaMinutes = (facility.distanceKm / 30 * 60).round();
    final badge = rank == 1 ? '??' : rank == 2 ? '??' : rank == 3 ? '??' : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (badge != null)
                          Text(badge, style: const TextStyle(fontSize: 18)),
                        if (badge != null) const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            facility.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (facility.verified) const VerifiedBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.navigation,
                            size: 14, color: AppDesignColors.success),
                        const SizedBox(width: 6),
                        Text(
                          '${facility.distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time,
                            size: 14, color: AppDesignColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '$etaMinutes min',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Call Now',
                  icon: Icons.call,
                  color: AppDesignColors.success,
                  onPressed: onCall,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Directions',
                  icon: Icons.navigation,
                  color: AppDesignColors.primary,
                  onPressed: onDirections,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    final etaMinutes =
        facility != null ? (facility.distanceKm / 30 * 60).round() : null;

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
                            style: TextStyle(
                                fontSize: 12, color: AppDesignColors.gray700),
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
                            child:
                                const Icon(Icons.place, color: Colors.white),
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
                            side:
                                const BorderSide(color: AppDesignColors.gray200),
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
