// lib/ui/emergency_flow/screens/location_screen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

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

  String status = "Detecting location…";

  double? detectedLat;
  double? detectedLng;

  String? detectedStateName;
  String? detectedLgaName;

  // Lookup tables
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> lgas = [];

  // Selected manually
  int? selectedStateId;
  int? selectedLgaId;
  String? selectedStateName;
  String? selectedLgaName;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  // ------------------------------------------------------------
  // STEP 1 → LOAD WP STATES + LGAs
  // ------------------------------------------------------------
  Future<void> _loadLookups() async {
    try {
      final s = await _api.fetchStates();
      final g = await _api.fetchLgas();

      states = List<Map<String, dynamic>>.from(s);
      lgas = List<Map<String, dynamic>>.from(g);
    } catch (e) {
      debugPrint("Lookup load failed: $e");
      states = [];
      lgas = [];
    }

    setState(() => loadingLookups = false);

    _autoLocate();
  }

  // ------------------------------------------------------------
  // STEP 2 → AUTO-DETECT GPS LOCATION
  // ------------------------------------------------------------
  Future<void> _autoLocate() async {
    setState(() {
      locating = true;
      status = "Detecting location…";
    });

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          locating = false;
          status = "Location services are off. Select manually below.";
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
          status = "Permission denied. Select manually below.";
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
      debugPrint("Auto-locate failed: $e");
      setState(() {
        locating = false;
        status = "Auto-detection failed. Select manually.";
      });
    }
  }

  // ------------------------------------------------------------
  // STEP 3 → REVERSE GEOCODE → MATCH TO WP TAXONOMY
  // ------------------------------------------------------------
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) throw "No placemarks";

      final p = placemarks.first;

      String? guessLGA = p.subAdministrativeArea;
      String? guessState = p.administrativeArea;

      // Fallback cases
      if ((guessLGA == null || guessLGA.isEmpty) &&
          (p.locality != null && p.locality!.isNotEmpty)) {
        guessLGA = p.locality;
      }

      detectedLgaName = guessLGA;
      detectedStateName = guessState;

      // Match to WP list
      _matchLocationToTaxonomy();
    } catch (e) {
      debugPrint("Reverse geocode failed: $e");
      setState(() {
        locating = false;
        status = "Coordinates found but cannot detect LGA. Select manually.";
      });
    }
  }

  // ------------------------------------------------------------
  // STEP 4 → MATCH “Ikeja”, “Ogun”, etc → WP taxonomy
  // ------------------------------------------------------------
  void _matchLocationToTaxonomy() {
    int? foundStateId;
    int? foundLgaId;

    // Match state
    if (detectedStateName != null) {
      final sLower = detectedStateName!.toLowerCase();
      for (var s in states) {
        if ((s["name"] ?? "").toString().toLowerCase().contains(sLower)) {
          foundStateId = s["id"];
          break;
        }
      }
    }

    // Match LGA
    if (detectedLgaName != null) {
      final lLower = detectedLgaName!.toLowerCase();
      for (var g in lgas) {
        if ((g["name"] ?? "").toString().toLowerCase().contains(lLower)) {
          foundLgaId = g["id"];
          break;
        }
      }
    }

    setState(() {
      selectingForContinue(foundStateId, foundLgaId);
      locating = false;

      status = (foundStateId != null || foundLgaId != null)
          ? "Detected: ${detectedLgaName ?? ''}, ${detectedStateName ?? ''}"
          : "Detected but unmatched; please correct manually.";
    });
  }

  // Helper → store matched selections
  void selectingForContinue(int? stId, int? lgId) {
    selectedStateId = stId;
    selectedLgaId = lgId;

    if (stId != null) {
      selectedStateName =
          states.firstWhere((e) => e["id"] == stId)["name"] as String?;
    }
    if (lgId != null) {
      selectedLgaName =
          lgas.firstWhere((e) => e["id"] == lgId)["name"] as String?;
    }
  }

  // ------------------------------------------------------------
  // STEP 5 → CONTINUE (AUTO OR MANUAL)
  // ------------------------------------------------------------
  void _continue() {
    if (selectedStateId == null || selectedLgaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select State & LGA")),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/emergency/select',
      arguments: {
        "stateId": selectedStateId,
        "stateName": selectedStateName,
        "lgaId": selectedLgaId,
        "lgaName": selectedLgaName,
        "latitude": detectedLat,
        "longitude": detectedLng,
      },
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detect Location")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // AUTO-DETECT CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, size: 30, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(child: Text(status)),
                    if (locating)
                      const CircularProgressIndicator(strokeWidth: 2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("OR", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),

            // MANUAL CARD
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
                                const InputDecoration(labelText: "State"),
                            items: states
                                .map((s) => DropdownMenuItem<int>(
                                      value: s["id"],
                                      child: Text(s["name"] ?? ""),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedStateId = v;
                                selectedStateName = states
                                    .firstWhere((e) => e["id"] == v)["name"];
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: selectedLgaId,
                            decoration: const InputDecoration(labelText: "LGA"),
                            items: lgas
                                .map((g) => DropdownMenuItem<int>(
                                      value: g["id"],
                                      child: Text(g["name"] ?? ""),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedLgaId = v;
                                selectedLgaName = lgas
                                    .firstWhere((e) => e["id"] == v)["name"];
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _autoLocate,
                                  child: const Text("Try again"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _continue,
                                  child: const Text("Continue"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            if (detectedLat != null)
              Text(
                "GPS: ${detectedLat!.toStringAsFixed(5)}, ${detectedLng!.toStringAsFixed(5)}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}
