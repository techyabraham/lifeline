// lib/models/trusted_contact.dart
class TrustedContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final bool isPriority;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.isPriority,
  });

  factory TrustedContact.fromMap(Map<dynamic, dynamic> map) {
    return TrustedContact(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      relationship: map['relationship']?.toString() ?? 'Friend',
      isPriority: map['isPriority'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'isPriority': isPriority,
      };
}
