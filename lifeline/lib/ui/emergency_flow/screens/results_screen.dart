// lib/ui/emergency_flow/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../flow_controller.dart';
import '../models/facility.dart';
import '../../../services/call_service.dart';

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
    final headerColor = ctrl.selectedType?.color ?? AppColors.brandBlue;
    final locationLabel =
        '${ctrl.selectedLga ?? 'Ikeja'}, ${ctrl.selectedState ?? 'Lagos'}';

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerColor, headerColor.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                        color: const Color(0xFFFDF2F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF9A8D4)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Also notify emergency contacts?',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Let your family know',
                                  style: TextStyle(
                                      color: AppColors.muted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => ctrl.setNotifyContacts(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEC4899),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            ),
                            child: const Text(
                              'Yes',
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
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: const Text(
                        'Contacts notified',
                        style: TextStyle(
                            color: AppColors.brandGreen,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (ctrl.loading) const LinearProgressIndicator(),
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
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _FacilityCard({
    required this.facility,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final etaMinutes = (facility.distanceKm / 30 * 60).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.navigation,
                              size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Text(
                            '${facility.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time,
                              size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            '$etaMinutes min',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          if (facility.verified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified,
                                      size: 14, color: AppColors.brandGreen),
                                  SizedBox(width: 6),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.brandGreen,
                                    ),
                                  ),
                                ],
                              ),
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
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call),
                    label: const Text('CALL NOW'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDirections,
                    icon: const Icon(Icons.navigation),
                    label: const Text('DIRECTIONS'),
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
  }
}
