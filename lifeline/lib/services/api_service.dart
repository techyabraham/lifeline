// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/emergency_contact.dart';

class ApiService {
  static const String _base = "https://lfl.tirafemz.com.ng/wp-json/wp/v2";

  // --------------------------------------------------
  // SERVICE CATEGORIES (taxonomy: service_category)
  // --------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchServiceCategories() async {
    final url = Uri.parse("$_base/service_category?per_page=100");

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load service categories');
    }

    return List<Map<String, dynamic>>.from(json.decode(res.body));
  }

  // --------------------------------------------------
  // STATES (taxonomy: state)
  // --------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchStates() async {
    final url = Uri.parse("$_base/state?per_page=200");

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load states');
    }

    return List<Map<String, dynamic>>.from(json.decode(res.body));
  }

  // --------------------------------------------------
  // LGAs (taxonomy: lga)
  // --------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchLgas() async {
    final url = Uri.parse("$_base/lga?per_page=500");

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load LGAs');
    }

    return List<Map<String, dynamic>>.from(json.decode(res.body));
  }

  // --------------------------------------------------
  // LGAs BY STATE (if parent relationship exists)
  // --------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchLgasByState(int stateId) async {
    final url = Uri.parse("$_base/lga?parent=$stateId&per_page=200");

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load LGAs for state');
    }

    return List<Map<String, dynamic>>.from(json.decode(res.body));
  }

  // --------------------------------------------------
  // EMERGENCY CONTACTS (CPT: emergency_contact)
  // --------------------------------------------------
  Future<List<EmergencyContact>> fetchContacts({
    int? serviceCategoryId,
    int? stateId,
    int? lgaId,
  }) async {
    final buffer = StringBuffer("$_base/emergency_contact?per_page=100");

    if (serviceCategoryId != null) {
      buffer.write("&service_category=$serviceCategoryId");
    }
    if (stateId != null) {
      buffer.write("&state=$stateId");
    }
    if (lgaId != null) {
      buffer.write("&lga=$lgaId");
    }

    final url = Uri.parse(buffer.toString());
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load emergency contacts');
    }

    final List data = json.decode(res.body);
    return data.map((e) => EmergencyContact.fromJson(e)).toList();
  }

  // --------------------------------------------------
  // SINGLE CONTACT
  // --------------------------------------------------
  Future<EmergencyContact> fetchSingle(int id) async {
    final url = Uri.parse("$_base/emergency_contact/$id");

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load contact');
    }

    return EmergencyContact.fromJson(json.decode(res.body));
  }
}
