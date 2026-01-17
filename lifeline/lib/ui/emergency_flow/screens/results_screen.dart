// lib/ui/emergency_flow/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../flow_controller.dart';
import '../models/facility.dart';

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
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      final ctrl = Provider.of<EmergencyFlowController>(context, listen: false);
      if (ctrl.notifyingContacts) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifying your contacts...')),
        );
      }
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final type = ctrl.selectedType?.title ?? 'Facility';

    return Scaffold(
      appBar: AppBar(title: Text('Nearest $type')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.place, color: AppColors.brandBlue),
                title: Text('Current Location: ${ctrl.selectedLga ?? 'Unknown'}'),
                subtitle: const Text('Sorted by distance'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Notify'),
                    Switch(
                      value: ctrl.notifyingContacts,
                      onChanged: (v) => ctrl.setNotifyContacts(v),
                    ),
                  ],
                ),
              ),
            ),
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
                          onMap: () => launchUrl(
                            Uri.parse('geo:0,0?q=${Uri.encodeComponent(f.name)}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/emergency/location'),
        icon: const Icon(Icons.sos),
        label: const Text('SOS'),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback onCall;
  final VoidCallback onMap;

  const _FacilityCard({
    required this.facility,
    required this.onCall,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                            '${facility.distanceKm.toStringAsFixed(1)} km away',
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
                const Icon(Icons.chevron_right, color: AppColors.muted),
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
                OutlinedButton(onPressed: onMap, child: const Icon(Icons.map)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
