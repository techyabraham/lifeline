import 'package:hive/hive.dart';
part 'contact_model.g.dart';

@HiveType(typeId: 0)
class ContactModel extends HiveObject {
  @HiveField(0)
  final String agency;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final String state;

  @HiveField(3)
  final String lga;

  @HiveField(4)
  final bool verified;

  @HiveField(5)
  final String category; // Police, Fire, Health, FRSC etc.

  ContactModel({
    required this.agency,
    required this.phone,
    required this.state,
    required this.lga,
    required this.verified,
    required this.category,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        agency: json['agency'],
        phone: json['phone'],
        state: json['state'],
        lga: json['lga'],
        verified: json['verified'],
        category: json['category'],
      );

  Map<String, dynamic> toJson() => {
        'agency': agency,
        'phone': phone,
        'state': state,
        'lga': lga,
        'verified': verified,
        'category': category,
      };
}
