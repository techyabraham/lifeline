// lib/ui/location/location_screen.dart
// Updated to use local GeoDataService dataset (offline) for State/LGA.
// Navigates to /emergency with:
// { "lgaId", "lgaName", "stateId", "stateName", "latitude", "longitude" }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../services/geo_data_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final GeoDataService _geo = GeoDataService.instance;

  String status = 'Detecting location...';
  bool locating = true;
  bool loadingLookups = true;
  String? detectedLgaName;
  String? detectedStateName;
  double? detectedLat;
  double? detectedLng;

  List<GeoState> states = [];
  List<GeoLga> lgas = [];

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
      await _geo.init();
      states = _geo.states;
      lgas = _geo.states.expand((s) => s.lgas).toList();
    } catch (e) {
      debugPrint('Failed to load lookups: $e');
      states = [];
      lgas = [];
    } finally {
      setState(() {
        loadingLookups = false;
      });

      await _tryAutoLocate();
    }
  }

  Future<void> _tryAutoLocate() async {
    setState(() {
      locating = true;
      status = 'Detecting location...';
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

      String? bestLga;
      String? bestState;
      try {
        final placemarks =
            await geo.placemarkFromCoordinates(detectedLat!, detectedLng!);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          bestLga = p.subAdministrativeArea?.trim();
          bestState = p.administrativeArea?.trim();

          if ((bestLga == null || bestLga.isEmpty) &&
              (p.locality?.isNotEmpty ?? false)) {
            bestLga = p.locality;
          }

          if (bestLga != null && bestLga!.isEmpty) bestLga = null;
          if (bestState != null && bestState!.isEmpty) bestState = null;
        }
      } catch (e) {
        debugPrint('Reverse geocoding failed: $e');
      }

      GeoState? matchedState;
      GeoLga? matchedLga;

      if (bestState != null) {
        matchedState = _geo.matchStateByName(bestState!);
      }

      if (bestLga != null) {
        matchedLga = _geo.matchLgaByName(matchedState?.id, bestLga!);
        matchedLga ??= _geo.matchLgaByName(null, bestLga!);
      }

      if (matchedState == null && matchedLga != null) {
        matchedState = states.firstWhere(
          (s) => s.id == matchedLga!.stateId,
          orElse: () => const GeoState(
            id: -1,
            name: '',
            displayName: '',
            slug: '',
            lgas: [],
          ),
        );
        if (matchedState.id == -1) matchedState = null;
      }

      setState(() {
        detectedLgaName = matchedLga?.name ?? bestLga;
        detectedStateName = matchedState?.displayName ?? bestState;
        locating = false;
        status = (matchedLga != null || matchedState != null)
            ? 'Located: ${detectedLgaName ?? ''}${detectedStateName != null ? ', $detectedStateName' : ''}'
            : 'Located coordinates, but could not map to LGA. Please select manually.';
        selectedLgaId = matchedLga?.id;
        selectedLgaName = matchedLga?.name;
        selectedStateId = matchedState?.id;
        selectedStateName = matchedState?.displayName;
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
    if (selectedStateId == null || selectedLgaId == null) {
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

    final stateLgas = selectedStateId == null
        ? lgas
        : _geo.lgasForState(selectedStateId!);

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
                          DropdownButtonFormField<int>(
                            value: selectedStateId,
                            decoration: const InputDecoration(labelText: 'State'),
                            items: states
                                .map((s) => DropdownMenuItem<int>(
                                      value: s.id,
                                      child: Text(s.displayName),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              final state =
                                  states.where((s) => s.id == val).toList();
                              final selected = state.isNotEmpty ? state.first : null;
                              setState(() {
                                selectedStateId = val;
                                selectedStateName = selected?.displayName;
                                final lgaList =
                                    val == null ? <GeoLga>[] : _geo.lgasForState(val);
                                final firstLga = lgaList.isNotEmpty ? lgaList.first : null;
                                selectedLgaId = firstLga?.id;
                                selectedLgaName = firstLga?.name;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: selectedLgaId,
                            decoration: const InputDecoration(labelText: 'LGA'),
                            items: stateLgas
                                .map((l) => DropdownMenuItem<int>(
                                      value: l.id,
                                      child: Text(l.name),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              final selected =
                                  stateLgas.where((e) => e.id == val).toList();
                              setState(() {
                                selectedLgaId = val;
                                selectedLgaName =
                                    selected.isNotEmpty ? selected.first.name : null;
                              });
                            },
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
