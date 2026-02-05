// lib/ui/emergency_flow/screens/location_screen.dart
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system.dart';
import '../../../services/geo_data_service.dart';
import '../../widgets/design_widgets.dart';
import '../flow_controller.dart';

class EmergencyLocationScreen extends StatefulWidget {
  const EmergencyLocationScreen({super.key});

  @override
  State<EmergencyLocationScreen> createState() =>
      _EmergencyLocationScreenState();
}

class _EmergencyLocationScreenState extends State<EmergencyLocationScreen> {
  final GeoDataService _geo = GeoDataService.instance;

  bool locating = true;
  bool loadingLookups = true;
  String searchQuery = '';

  String status = 'Detecting location...';

  double? detectedLat;
  double? detectedLng;
  Position? detectedPosition;

  String? detectedStateName;
  String? detectedLgaName;
  String? detectedAddress;

  List<GeoState> states = [];
  List<GeoLga> lgas = [];

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
      await _geo.init();
      states = _geo.states;
      lgas = _geo.states.expand((s) => s.lgas).toList();
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

      detectedPosition = pos;
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
      detectedAddress = _formatAddress(p);

      String? guessLga = p.subAdministrativeArea;
      String? guessState = p.administrativeArea;

      if ((guessLga == null || guessLga.isEmpty) &&
          (p.locality != null && p.locality!.isNotEmpty)) {
        guessLga = p.locality;
      }

      detectedLgaName = guessLga;
      detectedStateName = guessState;

      _matchLocationToDataset();
    } catch (e) {
      debugPrint('Reverse geocode failed: $e');
      setState(() {
        locating = false;
        status = 'Coordinates found but cannot detect LGA. Select manually.';
      });
    }
  }

  void _matchLocationToDataset() {
    GeoState? matchedState;
    GeoLga? matchedLga;

    if (detectedStateName != null && detectedStateName!.trim().isNotEmpty) {
      matchedState = _geo.matchStateByName(detectedStateName!);
    }

    if (detectedLgaName != null && detectedLgaName!.trim().isNotEmpty) {
      matchedLga = _geo.matchLgaByName(matchedState?.id, detectedLgaName!);
      if (matchedLga == null) {
        matchedLga = _geo.matchLgaByName(null, detectedLgaName!);
      }
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
      if (matchedState.id == -1) {
        matchedState = null;
      }
    }

    setState(() {
      selectingForContinue(matchedState, matchedLga);
      locating = false;

      status = (matchedState != null || matchedLga != null)
          ? 'Detected: ${detectedLgaName ?? ''}, ${detectedStateName ?? ''}'
          : 'Detected but unmatched; please correct manually.';
    });
  }

  String _formatAddress(geo.Placemark p) {
    final parts = [
      p.street,
      p.subLocality,
      p.locality,
      p.subAdministrativeArea,
      p.administrativeArea,
    ];
    final cleaned = parts
        .where((e) => e != null && e!.trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return cleaned.join(', ');
  }

  void selectingForContinue(GeoState? state, GeoLga? lga) {
    selectedStateId = state?.id;
    selectedStateName = state?.displayName;

    selectedLgaId = lga?.id;
    selectedLgaName = lga?.name;
  }

  void _continue() {
    if (selectedStateId == null || selectedLgaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select State & LGA')),
      );
      return;
    }

    final ctrl = Provider.of<EmergencyFlowController>(context, listen: false);
    ctrl.setLocation(
      state: selectedStateName ?? '',
      lga: selectedLgaName ?? '',
      position: detectedPosition,
    );

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
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final filteredStates = states.where((s) {
      final name = s.displayName.toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          s.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    final currentStateId = selectedStateId;
    final stateLgas = currentStateId == null
        ? lgas
        : _geo.lgasForState(currentStateId);

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
                  onChanged: (v) => setState(() => searchQuery = v),
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
                    width: double.infinity,
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
                        const Text(
                          'Finding You...',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18),
                        ),
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
                          onPressed: _autoLocate,
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
                            '${selectedLgaName ?? detectedLgaName ?? ctrl.selectedLga ?? 'Ikeja'}, ${selectedStateName ?? detectedStateName ?? ctrl.selectedState ?? 'Lagos State'}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (detectedAddress != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      detectedAddress!,
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
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
                      itemCount: filteredStates.length,
                      itemBuilder: (context, index) {
                        final s = filteredStates[index];
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
                            final stateLgaList = _geo.lgasForState(s.id);
                            final firstLga =
                                stateLgaList.isNotEmpty ? stateLgaList.first : null;
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
            child: PrimaryButton(
              label: 'Confirm Location',
              onPressed: (selectedStateId != null && selectedLgaId != null)
                  ? _continue
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
