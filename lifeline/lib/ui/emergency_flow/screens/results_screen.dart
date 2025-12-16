// lib/ui/emergency_flow/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _call(String phone, Facility facility) async {
    // No confirmation per spec. We will open dialer (safer) using tel:
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      // notify contacts if toggled
      final ctrl = Provider.of<EmergencyFlowController>(context, listen: false);
      if (ctrl.notifyingContacts) {
        // TODO: implement notify via server or SMS intent
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifying your contacts...')));
      }
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open dialer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final type = ctrl.selectedType?.title ?? 'Facility';

    return Scaffold(
      appBar: AppBar(title: Text('Nearest $type')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.place),
              title: Text('Location: ${ctrl.selectedLga ?? 'Unknown'}'),
              subtitle: const Text('Sorted by distance'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Notify'),
                Switch(
                    value: ctrl.notifyingContacts,
                    onChanged: (v) => ctrl.setNotifyContacts(v)),
              ]),
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
                        rankEmoji: i == 0
                            ? '🥇'
                            : i == 1
                                ? '🥈'
                                : '🥉',
                        onCall: () => _call(f.phone, f),
                        onMap: () => launchUrl(Uri.parse(
                            'geo:0,0?q=${Uri.encodeComponent(f.name)}')),
                        onTryNext: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text('Try next facility'))),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final Facility facility;
  final String rankEmoji;
  final VoidCallback onCall;
  final VoidCallback onMap;
  final VoidCallback onTryNext;

  const _FacilityCard({
    required this.facility,
    required this.rankEmoji,
    required this.onCall,
    required this.onMap,
    required this.onTryNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(facility.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.navigation,
                          size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text(
                          '${facility.distanceKm.toStringAsFixed(1)} km • ETA N/A',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      if (facility.verified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(children: const [
                            Icon(Icons.verified, size: 14, color: Colors.green),
                            SizedBox(width: 6),
                            Text('Verified',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.green)),
                          ]),
                        ),
                    ]),
                  ]),
            ),
            Text(rankEmoji, style: const TextStyle(fontSize: 28)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.call),
                label: const Text('CALL NOW'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onMap, child: const Icon(Icons.map)),
          ]),
        ]),
      ),
    );
  }
}
