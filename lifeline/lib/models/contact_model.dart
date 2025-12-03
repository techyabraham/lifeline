class ContactModel {
  final String agency;
  final String phone;
  final String state;
  final String lga;
  final String category;
  final bool verified;

  ContactModel({
    required this.agency,
    required this.phone,
    required this.state,
    required this.lga,
    required this.category,
    required this.verified,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        agency: json['agency'],
        phone: json['phone'],
        state: json['state'],
        lga: json['lga'],
        category: json['category'],
        verified: json['verified'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'agency': agency,
        'phone': phone,
        'state': state,
        'lga': lga,
        'category': category,
        'verified': verified,
      };
}
