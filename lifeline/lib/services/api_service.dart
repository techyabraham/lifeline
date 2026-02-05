// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/emergency_contact.dart';

class ApiService {
  static const String _base = "https://lfl.tirafemz.com.ng/wp-json/wp/v2";

  Future<List<Map<String, dynamic>>> _fetchPaged(
    String endpoint, {
    Map<String, String>? query,
  }) async {
    final List<Map<String, dynamic>> all = [];
    int page = 1;
    int totalPages = 1;

    do {
      final qp = <String, String>{
        'per_page': '100',
        'page': page.toString(),
        if (query != null) ...query,
      };
      final uri =
          Uri.parse("$_base/$endpoint").replace(queryParameters: qp);
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('Failed to load $endpoint');
      }

      final List data = json.decode(res.body);
      all.addAll(List<Map<String, dynamic>>.from(data));

      final header = res.headers['x-wp-totalpages'];
      totalPages = header != null ? int.tryParse(header) ?? page : page;
      page++;
    } while (page <= totalPages);

    return all;
  }

  // --------------------------------------------------
  // SERVICE CATEGORIES (taxonomy: service_category)
  // --------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchServiceCategories() async {
    return _fetchPaged('service_category');
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    return fetchServiceCategories();
  }

  // --------------------------------------------------
  // STATES (taxonomy: state)
  // --------------------------------------------------
  @Deprecated("Use GeoDataService (local dataset).")
  Future<List<Map<String, dynamic>>> fetchStates() async {
    return _fetchPaged('state');
  }

  // --------------------------------------------------
  // LGAs (taxonomy: lga)
  // --------------------------------------------------
  @Deprecated("Use GeoDataService (local dataset).")
  Future<List<Map<String, dynamic>>> fetchLgas() async {
    return _fetchPaged('lga');
  }

  // --------------------------------------------------
  // LGAs BY STATE (if parent relationship exists)
  // --------------------------------------------------
  @Deprecated("Use GeoDataService (local dataset).")
  Future<List<Map<String, dynamic>>> fetchLgasByState(int stateId) async {
    return _fetchPaged('lga', query: {'parent': stateId.toString()});
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
