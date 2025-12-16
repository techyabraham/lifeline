// lib/ui/emergency_flow/models/facility.dart
class Facility {
  final String id;
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final bool verified;
  final double distanceKm; // computed client-side

  Facility({
    required this.id,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.verified,
    required this.distanceKm,
  });

  factory Facility.fromJson(Map<String, dynamic> json, double distanceKm) {
    return Facility(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      latitude: (json['lat'] ?? 0).toDouble(),
      longitude: (json['lng'] ?? 0).toDouble(),
      verified: (json['verified'] ?? false) as bool,
      distanceKm: distanceKm,
    );
  }
}
