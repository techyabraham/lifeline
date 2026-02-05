// lib/ui/location/location_screen.dart
// Updated to use local GeoDataService dataset (offline) for State/LGA.
// Navigates to /emergency with:
// { "lgaId", "lgaName", "stateId", "stateName", "latitude", "longitude" }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../config/design_system.dart';
import '../../services/geo_data_service.dart';
import '../widgets/design_widgets.dart';

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
            ? 'Detected: ${detectedLgaName ?? ''}${detectedStateName != null ? ', $detectedStateName' : ''}'
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
    final stateLgas = selectedStateId == null
        ? lgas
        : _geo.lgasForState(selectedStateId!);

    return Scaffold(
      backgroundColor: AppDesignColors.gray50,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 6),
                    const Text('Select Location', style: AppTextStyles.h2),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppDesignColors.gray400),
                    hintText: 'Search state or LGA...',
                    filled: true,
                    fillColor: AppDesignColors.gray50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      borderSide: const BorderSide(color: AppDesignColors.gray200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      borderSide: const BorderSide(color: AppDesignColors.primary, width: 1.5),
                    ),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.navigation, color: Colors.white, size: 34),
                        ),
                        const SizedBox(height: 10),
                        const Text('Finding You...',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          locating ? 'Using GPS' : status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          label: 'Try again',
                          icon: Icons.my_location,
                          onPressed: _tryAutoLocate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      border: Border.all(color: AppDesignColors.primary),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppDesignColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${selectedLgaName ?? detectedLgaName ?? 'Ikeja'}, ${selectedStateName ?? detectedStateName ?? 'Lagos State'}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Select State', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  if (loadingLookups)
                    const LoadingState(message: 'Loading states...')
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.1,
                      ),
                      itemCount: states.length,
                      itemBuilder: (context, index) {
                        final s = states[index];
                        final isSelected = selectedStateId == s.id;
                        return OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AppDesignColors.primary
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : AppDesignColors.gray900,
                            side: BorderSide(
                              color: isSelected
                                  ? AppDesignColors.primary
                                  : AppDesignColors.gray200,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                          onPressed: () {
                            final lgaList = _geo.lgasForState(s.id);
                            final firstLga = lgaList.isNotEmpty ? lgaList.first : null;
                            setState(() {
                              selectedStateId = s.id;
                              selectedStateName = s.displayName;
                              selectedLgaId = firstLga?.id;
                              selectedLgaName = firstLga?.name;
                            });
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(s.displayName),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  if (selectedStateName != null)
                    Text('Select LGA in $selectedStateName',
                        style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  ...stateLgas.map((g) {
                    final isSelected = selectedLgaId == g.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppDesignColors.primary
                              : Colors.white,
                          foregroundColor: isSelected
                              ? Colors.white
                              : AppDesignColors.gray900,
                          side: BorderSide(
                            color: isSelected
                                ? AppDesignColors.primary
                                : AppDesignColors.gray200,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedLgaId = g.id;
                            selectedLgaName = g.name;
                          });
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(g.name),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: AppShadows.subtle,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Continue manually',
                    onPressed: _continueWithManual,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Confirm',
                    onPressed: (selectedStateId != null && selectedLgaId != null)
                        ? _continueWithManual
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
