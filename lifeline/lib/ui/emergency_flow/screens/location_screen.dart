// lib/ui/emergency_flow/screens/location_screen.dart
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import '../../../config/theme.dart';
import '../../../services/api_service.dart';

class EmergencyLocationScreen extends StatefulWidget {
  const EmergencyLocationScreen({super.key});

  @override
  State<EmergencyLocationScreen> createState() =>
      _EmergencyLocationScreenState();
}

class _EmergencyLocationScreenState extends State<EmergencyLocationScreen> {
  final ApiService _api = ApiService();

  bool locating = true;
  bool loadingLookups = true;

  String status = 'Detecting location...';

  double? detectedLat;
  double? detectedLng;

  String? detectedStateName;
  String? detectedLgaName;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> lgas = [];

  int? selectedStateId;
  int? selectedLgaId;
  String? selectedStateName;
  String? selectedLgaName;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final s = await _api.fetchStates();
      final g = await _api.fetchLgas();

      states = List<Map<String, dynamic>>.from(s);
      lgas = List<Map<String, dynamic>>.from(g);
    } catch (e) {
      debugPrint('Lookup load failed: $e');
      states = [];
      lgas = [];
    }

    setState(() => loadingLookups = false);
    _autoLocate();
  }

  Future<void> _autoLocate() async {
    setState(() {
      locating = true;
      status = 'Detecting location...';
    });

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          locating = false;
          status = 'Location services are off. Select manually below.';
        });
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() {
          locating = false;
          status = 'Permission denied. Select manually below.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      detectedLat = pos.latitude;
      detectedLng = pos.longitude;

      await _reverseGeocode(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('Auto-locate failed: $e');
      setState(() {
        locating = false;
        status = 'Auto-detection failed. Select manually.';
      });
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) throw 'No placemarks';

      final p = placemarks.first;

      String? guessLga = p.subAdministrativeArea;
      String? guessState = p.administrativeArea;

      if ((guessLga == null || guessLga.isEmpty) &&
          (p.locality != null && p.locality!.isNotEmpty)) {
        guessLga = p.locality;
      }

      detectedLgaName = guessLga;
      detectedStateName = guessState;

      _matchLocationToTaxonomy();
    } catch (e) {
      debugPrint('Reverse geocode failed: $e');
      setState(() {
        locating = false;
        status = 'Coordinates found but cannot detect LGA. Select manually.';
      });
    }
  }

  void _matchLocationToTaxonomy() {
    int? foundStateId;
    int? foundLgaId;

    if (detectedStateName != null) {
      final sLower = detectedStateName!.toLowerCase();
      for (var s in states) {
        if ((s['name'] ?? '').toString().toLowerCase().contains(sLower)) {
          foundStateId = s['id'];
          break;
        }
      }
    }

    if (detectedLgaName != null) {
      final lLower = detectedLgaName!.toLowerCase();
      for (var g in lgas) {
        if ((g['name'] ?? '').toString().toLowerCase().contains(lLower)) {
          foundLgaId = g['id'];
          break;
        }
      }
    }

    setState(() {
      selectingForContinue(foundStateId, foundLgaId);
      locating = false;

      status = (foundStateId != null || foundLgaId != null)
          ? 'Detected: ${detectedLgaName ?? ''}, ${detectedStateName ?? ''}'
          : 'Detected but unmatched; please correct manually.';
    });
  }

  void selectingForContinue(int? stId, int? lgId) {
    selectedStateId = stId;
    selectedLgaId = lgId;

    if (stId != null) {
      selectedStateName =
          states.firstWhere((e) => e['id'] == stId)['name'] as String?;
    }
    if (lgId != null) {
      selectedLgaName =
          lgas.firstWhere((e) => e['id'] == lgId)['name'] as String?;
    }
  }

  void _continue() {
    if (selectedStateId == null || selectedLgaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select State & LGA')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/emergency/select',
      arguments: {
        'stateId': selectedStateId,
        'stateName': selectedStateName,
        'lgaId': selectedLgaId,
        'lgaName': selectedLgaName,
        'latitude': detectedLat,
        'longitude': detectedLng,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Location Detection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.gps_fixed,
                          color: AppColors.brandBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (locating)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Your Area',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: loadingLookups
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: selectedStateId,
                            decoration:
                                const InputDecoration(labelText: 'Select State'),
                            items: states
                                .map((s) => DropdownMenuItem<int>(
                                      value: s['id'],
                                      child: Text(s['name'] ?? ''),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedStateId = v;
                                selectedStateName = states
                                    .firstWhere((e) => e['id'] == v)['name'];
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: selectedLgaId,
                            decoration:
                                const InputDecoration(labelText: 'Select LGA'),
                            items: lgas
                                .map((g) => DropdownMenuItem<int>(
                                      value: g['id'],
                                      child: Text(g['name'] ?? ''),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedLgaId = v;
                                selectedLgaName = lgas
                                    .firstWhere((e) => e['id'] == v)['name'];
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _autoLocate,
                                  child: const Text('Try again'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _continue,
                                  child: const Text('Next'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (detectedLat != null)
              Text(
                'GPS: ${detectedLat!.toStringAsFixed(5)}, ${detectedLng!.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
          ],
        ),
      ),
    );
  }
}
