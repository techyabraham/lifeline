// lib/ui/results/results_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/api_service.dart';
import '../../models/emergency_contact.dart';
import '../calling/calling_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;

  List<EmergencyContact> _contacts = [];
  final Map<int, double> _distanceKm = {};

  bool _notifyContacts = false;

  // Route arguments
  int? categoryId;
  String? categoryName;
  int? lgaId;
  String? lgaName;
  int? stateId;
  String? stateName;
  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    categoryId = args['categoryId'];
    categoryName = args['categoryName'];

    lgaId = args['lgaId'];
    lgaName = args['lgaName'];
    stateId = args['stateId'];
    stateName = args['stateName'];

    userLat = args['latitude'];
    userLng = args['longitude'];

    if (userLat == null || userLng == null) {
      try {
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null) {
          userLat = pos.latitude;
          userLng = pos.longitude;
        }
      } catch (_) {}
    }

    await _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _loading = true;
      _error = null;
      _distanceKm.clear();
    });

    try {
      final fetched = await _api.fetchContacts(
        serviceCategoryId: categoryId,
        stateId: stateId,
        lgaId: lgaId,
      );

      for (final c in fetched) {
        double dist = double.infinity;

        if (userLat != null &&
            userLng != null &&
            c.latitude != null &&
            c.longitude != null) {
          dist = Geolocator.distanceBetween(
                userLat!,
                userLng!,
                c.latitude!,
                c.longitude!,
              ) /
              1000;
        }

        _distanceKm[c.id] = dist;
      }

      fetched.sort((a, b) => (_distanceKm[a.id] ?? double.infinity)
          .compareTo(_distanceKm[b.id] ?? double.infinity));

      setState(() {
        _contacts = fetched;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load emergency providers';
        _loading = false;
      });
    }
  }

  Future<void> _dial(EmergencyContact c) async {
    final uri = Uri(scheme: 'tel', path: c.phoneNumber);

    if (await canLaunchUrl(uri)) {
      // Optional: trigger notifications here if enabled
      if (_notifyContacts) {
        // hook for SMS / server notification
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CallingScreen(providerName: c.name, phone: c.phoneNumber),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 250));
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to place call')),
      );
    }
  }

  Future<void> _openMaps(EmergencyContact c) async {
    if (c.latitude != null && c.longitude != null) {
      final geo = Uri.parse(
          'geo:${c.latitude},${c.longitude}?q=${Uri.encodeComponent(c.name)}');

      if (await canLaunchUrl(geo)) {
        await launchUrl(geo);
        return;
      }
    }

    final query = Uri.encodeComponent('${c.name} ${c.address}');
    final web =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(web)) {
      await launchUrl(web);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = categoryName ?? 'Emergency';

    return Scaffold(
      appBar: AppBar(title: Text('Nearest • $title')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.place),
                title: Text(lgaName ?? stateName ?? 'Unknown location'),
                subtitle: const Text('Sorted by distance'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Notify'),
                    Switch(
                      value: _notifyContacts,
                      onChanged: (v) => setState(() => _notifyContacts = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadContacts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_contacts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No emergency providers found'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (_, index) {
                    final c = _contacts[index];
                    final dist = _distanceKm[c.id];

                    final emoji = index == 0
                        ? '🥇'
                        : index == 1
                            ? '🥈'
                            : index == 2
                                ? '🥉'
                                : '';

                    return _FacilityCard(
                      contact: c,
                      distanceKm: dist,
                      rankEmoji: emoji,
                      onCall: () => _dial(c),
                      onMap: () => _openMaps(c),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final EmergencyContact contact;
  final double? distanceKm;
  final String rankEmoji;
  final VoidCallback onCall;
  final VoidCallback onMap;

  const _FacilityCard({
    required this.contact,
    required this.distanceKm,
    required this.rankEmoji,
    required this.onCall,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.navigation,
                              size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            distanceKm != null
                                ? '${distanceKm!.toStringAsFixed(1)} km'
                                : '—',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          if (contact.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(children: [
                                Icon(Icons.verified,
                                    size: 14, color: Colors.green),
                                SizedBox(width: 4),
                                Text('Verified',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.green)),
                              ]),
                            ),
                        ]),
                        const SizedBox(height: 6),
                        Text(contact.address,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                        if (contact.secondaryPhone != null &&
                            contact.secondaryPhone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Alt: ${contact.secondaryPhone}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black45)),
                          ),
                      ]),
                ),
                Text(rankEmoji, style: const TextStyle(fontSize: 28)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call),
                    label: const Text('CALL NOW'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onMap,
                  child: const Icon(Icons.map),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
