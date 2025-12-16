// lib/models/emergency_contact.dart
class EmergencyContact {
  final int id;
  final String name;
  final String phoneNumber;
  final String? secondaryPhone;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final List<int> serviceCategories;
  final int? state;
  final int? lga;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.secondaryPhone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isVerified,
    required this.serviceCategories,
    this.state,
    this.lga,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    final acf = json['acf'] ?? {};

    return EmergencyContact(
      id: json['id'],
      name: json['title']?['rendered'] ?? '',
      phoneNumber: acf['phone_number'] ?? '',
      secondaryPhone: acf['secondary_phone'],
      address: acf['address'] ?? '',
      latitude: _toDouble(acf['latitude']),
      longitude: _toDouble(acf['longitude']),
      isVerified:
          (acf['is_verified'] ?? 'False').toString().toLowerCase() == 'true',
      serviceCategories: (json['service_category'] as List<dynamic>? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
      state: (json['state'] != null &&
              json['state'] is List &&
              json['state'].isNotEmpty)
          ? int.tryParse(json['state'][0].toString())
          : null,
      lga:
          (json['lga'] != null && json['lga'] is List && json['lga'].isNotEmpty)
              ? int.tryParse(json['lga'][0].toString())
              : null,
    );
  }
}

double? _toDouble(value) {
  if (value == null) return null;
  return double.tryParse(value.toString());
}
