// lib/ui/location/location_screen.dart
// Updated to use real ApiService (Headless WP), reverse-geocode, and live State/LGA lists.
// Expects an ApiService with methods: fetchStates() -> List<Map>, fetchLgas() -> List<Map>
// and that each state/lga item has keys: id, name, slug.
// Navigates to /emergency with:
// { "lgaId", "lgaName", "stateId", "stateName", "latitude", "longitude" }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../services/api_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final ApiService _api = ApiService();

  String status = 'Detecting location…';
  bool locating = true;
  bool loadingLookups = true;
  String? detectedLgaName;
  String? detectedStateName;
  double? detectedLat;
  double? detectedLng;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> lgas = [];

  // Manual selection values (store id when possible)
  int? selectedStateId;
  int? selectedLgaId;
  String? selectedStateName;
  String? selectedLgaName;

  @override
  void initState() {
    super.initState();
    _loadLookupsAndLocate();
  }

  Future<void> _loadLookupsAndLocate() async {
    setState(() {
      loadingLookups = true;
    });

    try {
      // Fetch states & lgas (live from WP)
      final fetchedStates = await _api.fetchStates();
      final fetchedLgas = await _api.fetchLgas();

      // Normalize to map list with id/name for easy use in dropdowns
      states = List<Map<String, dynamic>>.from(fetchedStates.map((m) {
        return {
          'id': m['id'],
          'name': (m['name'] ?? '').toString(),
          'slug': m['slug'] ?? '',
        };
      }));

      lgas = List<Map<String, dynamic>>.from(fetchedLgas.map((m) {
        return {
          'id': m['id'],
          'name': (m['name'] ?? '').toString(),
          'slug': m['slug'] ?? '',
        };
      }));
    } catch (e) {
      // If lookup fetch fails, still allow manual text entry later
      debugPrint('Failed to load lookups: $e');
      states = [];
      lgas = [];
    } finally {
      setState(() {
        loadingLookups = false;
      });

      // Try auto-locate after lookups load
      await _tryAutoLocate();
    }
  }

  Future<void> _tryAutoLocate() async {
    setState(() {
      locating = true;
      status = 'Detecting location…';
      detectedLgaName = null;
      detectedStateName = null;
      detectedLat = null;
      detectedLng = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          status = 'Location services disabled. Use manual selection below.';
          locating = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            status = 'Location permission denied. Use manual selection below.';
            locating = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          status =
              'Location permission permanently denied. Use manual selection below.';
          locating = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      detectedLat = pos.latitude;
      detectedLng = pos.longitude;

      // Reverse geocode using platform geocoder to get locality/state info
      String? bestLga;
      String? bestState;
      try {
        final placemarks =
            await geo.placemarkFromCoordinates(detectedLat!, detectedLng!);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          // Common fields: subAdministrativeArea (LGA), administrativeArea (state), locality (city)
          bestLga = p.subAdministrativeArea?.trim();
          bestState = p.administrativeArea?.trim();

          // Sometimes locality contains LGA; try fallback
          if ((bestLga == null || bestLga.isEmpty) &&
              (p.locality?.isNotEmpty ?? false)) {
            bestLga = p.locality;
          }

          // Normalize
          if (bestLga != null && bestLga.isEmpty) bestLga = null;
          if (bestState != null && bestState.isEmpty) bestState = null;
        }
      } catch (e) {
        debugPrint('Reverse geocoding failed: $e');
      }

      // Best-effort match with WP LGA list: case-insensitive substring match
      int? matchedLgaId;
      int? matchedStateId;
      String? matchedLgaName;
      String? matchedStateName;

      if (bestLga != null) {
        final lower = bestLga.toLowerCase();
        for (var l in lgas) {
          final name = (l['name'] ?? '').toString().toLowerCase();
          if (name.contains(lower) || lower.contains(name)) {
            matchedLgaId = l['id'] as int?;
            matchedLgaName = l['name'] as String?;
            break;
          }
        }
      }

      if (bestState != null) {
        final lower = bestState.toLowerCase();
        for (var s in states) {
          final name = (s['name'] ?? '').toString().toLowerCase();
          if (name.contains(lower) || lower.contains(name)) {
            matchedStateId = s['id'] as int?;
            matchedStateName = s['name'] as String?;
            break;
          }
        }
      }

      // If no matched LGA but we have state matched, try to find likely LGA by comparing locality
      if (matchedLgaId == null && bestLga != null && states.isNotEmpty) {
        // Try a looser match: find first LGA that contains first word of bestLga
        final tokens = bestLga
            .split(RegExp(r'[\s,-/]'))
            .where((t) => t.isNotEmpty)
            .toList();
        if (tokens.isNotEmpty) {
          final token = tokens.first.toLowerCase();
          for (var l in lgas) {
            final name = (l['name'] ?? '').toString().toLowerCase();
            if (name.contains(token) || token.contains(name)) {
              matchedLgaId = l['id'] as int?;
              matchedLgaName = l['name'] as String?;
              break;
            }
          }
        }
      }

      setState(() {
        detectedLgaName = matchedLgaName ?? bestLga;
        detectedStateName = matchedStateName ?? bestState;
        locating = false;
        status = (matchedLgaName != null || matchedStateName != null)
            ? 'Located: ${detectedLgaName ?? ''}${detectedStateName != null ? ', $detectedStateName' : ''}'
            : 'Located coordinates, but could not map to LGA. Please select manually.';
        // Save matched ids to selected fields — user can edit before continue
        selectedLgaId = matchedLgaId;
        selectedLgaName = matchedLgaName;
        selectedStateId = matchedStateId;
        selectedStateName = matchedStateName;
      });
    } catch (e) {
      debugPrint('Auto-locate error: $e');
      setState(() {
        locating = false;
        status = 'Auto-detection failed. Use manual selection below.';
      });
    }
  }

  void _continueWithDetected() {
    if (detectedLat == null || detectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No detected coordinates available')));
      return;
    }

    // If we have matched ids prefer them; otherwise pass names
    Navigator.pushNamed(context, '/emergency', arguments: {
      'lgaId': selectedLgaId,
      'lgaName': selectedLgaName ?? detectedLgaName,
      'stateId': selectedStateId,
      'stateName': selectedStateName ?? detectedStateName,
      'latitude': detectedLat,
      'longitude': detectedLng,
    });
  }

  void _continueWithManual() {
    if ((selectedStateId == null &&
            (selectedStateName == null || selectedStateName!.isEmpty)) ||
        (selectedLgaId == null &&
            (selectedLgaName == null || selectedLgaName!.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a State and LGA')));
      return;
    }

    Navigator.pushNamed(context, '/emergency', arguments: {
      'lgaId': selectedLgaId,
      'lgaName': selectedLgaName,
      'stateId': selectedStateId,
      'stateName': selectedStateName,
      'latitude': null,
      'longitude': null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFFF3B30);
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
    final safeBottom = (bottomSafe < 12) ? 16.0 : bottomSafe + 8.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detect Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gps_fixed, color: accent),
                        const SizedBox(width: 12),
                        Expanded(child: Text(status)),
                        if (locating) const SizedBox(width: 16),
                        if (locating)
                          const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!locating &&
                        (detectedLgaName != null || detectedStateName != null))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                              'Detected: ${detectedLgaName ?? 'Unknown LGA'}${detectedStateName != null ? ', $detectedStateName' : ''}'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _continueWithDetected,
                            icon: const Icon(Icons.check),
                            label: const Text('Use detected location'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),
            const Text('OR', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 14),

            // Manual selection using live dropdowns if available
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: loadingLookups
                    ? SizedBox(
                        height: 140,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Loading States & LGAs...'),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // State dropdown (if states available) or fallback TextField
                          states.isNotEmpty
                              ? DropdownButtonFormField<int>(
                                  value: selectedStateId,
                                  decoration:
                                      const InputDecoration(labelText: 'State'),
                                  items: states
                                      .map((s) => DropdownMenuItem<int>(
                                            value: s['id'] as int,
                                            child: Text(s['name'] ?? ''),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedStateId = val;
                                      selectedStateName = (states.firstWhere(
                                                  (e) =>
                                                      e['id'] == val)['name'] ??
                                              '')
                                          .toString();
                                      // Optionally filter LGAs list to those belonging to this state if your WP provides parent relationships
                                    });
                                  },
                                )
                              : TextFormField(
                                  initialValue: selectedStateName,
                                  decoration: const InputDecoration(
                                      labelText: 'State (type)'),
                                  onChanged: (v) =>
                                      selectedStateName = v.trim(),
                                ),
                          const SizedBox(height: 8),
                          // LGA dropdown or fallback
                          lgas.isNotEmpty
                              ? DropdownButtonFormField<int>(
                                  value: selectedLgaId,
                                  decoration:
                                      const InputDecoration(labelText: 'LGA'),
                                  items: lgas
                                      .map((l) => DropdownMenuItem<int>(
                                            value: l['id'] as int,
                                            child: Text(l['name'] ?? ''),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedLgaId = val;
                                      selectedLgaName = (lgas.firstWhere((e) =>
                                                  e['id'] == val)['name'] ??
                                              '')
                                          .toString();
                                    });
                                  },
                                )
                              : TextFormField(
                                  initialValue: selectedLgaName,
                                  decoration: const InputDecoration(
                                      labelText: 'LGA (type)'),
                                  onChanged: (v) => selectedLgaName = v.trim(),
                                ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await _tryAutoLocate();
                                  },
                                  child: const Text('Try again'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _continueWithManual,
                                  child: const Text('Continue'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 12),
            const Text('Location will be used to show nearest facilities.'),
            const Spacer(),

            // Small helper: show coordinates if available
            if (detectedLat != null && detectedLng != null)
              Text(
                  'Detected coords: ${detectedLat!.toStringAsFixed(5)}, ${detectedLng!.toStringAsFixed(5)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),

            SizedBox(height: safeBottom),
          ],
        ),
      ),
    );
  }
}
