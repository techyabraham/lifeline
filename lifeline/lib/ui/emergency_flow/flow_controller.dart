// lib/ui/emergency_flow/flow_controller.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'models/emergency_type.dart';
import 'models/facility.dart';

/// EmergencyFlowController: holds flow state, location, selected type,
/// list of facilities (fetched from API), and handles user actions.
///
/// Replace the _fetchFacilitiesFromApi mock with your real ApiService/Repository call.
class EmergencyFlowController extends ChangeNotifier {
  Position? currentPosition;
  String? selectedState;
  String? selectedLga;
  EmergencyType? selectedType;
  List<Facility> facilities = [];
  bool loading = false;
  bool notifyingContacts = false;

  // Set the current coords (after geolocation or manual selection)
  void setLocation(
      {required String state, required String lga, Position? position}) {
    selectedState = state;
    selectedLga = lga;
    currentPosition = position;
    notifyListeners();
  }

  Future<void> tryAutoLocate(
      {Duration timeout = const Duration(seconds: 8)}) async {
    loading = true;
    notifyListeners();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high, timeLimit: timeout);
      currentPosition = pos;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void pickType(EmergencyType type) {
    selectedType = type;
    facilities = [];
    notifyListeners();
  }

  Future<void> loadFacilities() async {
    // Must have LGA (or fallback to position)
    loading = true;
    notifyListeners();
    try {
      // TODO: Replace this mock with your WP headless / ApiService call
      final raw = await _fetchFacilitiesFromApi(
          selectedLga ?? selectedState ?? 'Unknown',
          selectedType?.id ?? 'hospital');
      // compute distance from currentPosition
      facilities = raw.map((r) {
        final lat = (r['lat'] ?? 0).toDouble();
        final lng = (r['lng'] ?? 0).toDouble();
        final dist = _distanceKm(currentPosition?.latitude ?? 0,
            currentPosition?.longitude ?? 0, lat, lng);
        return Facility.fromJson(r, dist);
      }).toList();
      facilities.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setNotifyContacts(bool v) async {
    notifyingContacts = v;
    notifyListeners();
  }

  // Mock API fetch — replace with real HTTP call to WP endpoint
  Future<List<Map<String, dynamic>>> _fetchFacilitiesFromApi(
      String lga, String type) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    // NOTE: in production, call your ContactsRepository.getContacts(lga: lga, type: type)
    return [
      {
        'id': '1',
        'name': 'Lagos University Teaching Hospital',
        'phone': '+2348030000000',
        'lat': 6.6050,
        'lng': 3.3492,
        'verified': true,
      },
      {
        'id': '2',
        'name': 'Reddington Hospital',
        'phone': '+2348020000000',
        'lat': 6.5725,
        'lng': 3.3883,
        'verified': true,
      },
      {
        'id': '3',
        'name': 'St. Nicholas Hospital',
        'phone': '+2348050000000',
        'lat': 6.5679,
        'lng': 3.3700,
        'verified': false,
      },
    ];
  }

  // Haversine formula in km
  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}
