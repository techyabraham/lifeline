// lib/models/contact_model.dart
import 'emergency_contact.dart';

class ContactModel {
  final int id;
  final String agency;
  final String phone;
  final String state;
  final String lga;
  final String category;
  final bool verified;

  ContactModel({
    required this.id,
    required this.agency,
    required this.phone,
    required this.state,
    required this.lga,
    required this.category,
    required this.verified,
  });

  /// ---------------------------------------------------
  /// FACTORY: Convert EmergencyContact → ContactModel
  /// Used by SearchScreen & ContactCard
  /// ---------------------------------------------------
  factory ContactModel.fromEmergency(EmergencyContact c,
      {String? stateName, String? lgaName, String? categoryName}) {
    return ContactModel(
      id: c.id,
      agency: c.name,
      phone: c.phoneNumber,
      state: stateName ?? 'Unknown',
      lga: lgaName ?? 'Unknown',
      category: categoryName ?? 'Emergency',
      verified: c.isVerified,
    );
  }

  /// ---------------------------------------------------
  /// LEGACY SUPPORT (optional)
  /// If any cached or older JSON still uses this
  /// ---------------------------------------------------
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] ?? 0,
      agency: json['agency'] ?? '',
      phone: json['phone'] ?? '',
      state: json['state'] ?? '',
      lga: json['lga'] ?? '',
      category: json['category'] ?? '',
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'agency': agency,
        'phone': phone,
        'state': state,
        'lga': lga,
        'category': category,
        'verified': verified,
      };
}
