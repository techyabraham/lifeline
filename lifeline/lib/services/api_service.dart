import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://your-wordpress-site.com/wp-json/lifeline/v1";

  Future<List<String>> fetchStates() async {
    final res = await http.get(Uri.parse('$baseUrl/states'));
    if (res.statusCode == 200) return List<String>.from(jsonDecode(res.body));
    throw Exception('Failed to load states');
  }

  Future<List<String>> fetchLGAs(String state) async {
    final res = await http.get(Uri.parse('$baseUrl/lgas?state=$state'));
    if (res.statusCode == 200) return List<String>.from(jsonDecode(res.body));
    throw Exception('Failed to load LGAs');
  }

  Future<List<Map<String, dynamic>>> fetchContacts(String lga) async {
    final res = await http.get(Uri.parse('$baseUrl/contacts?lga=$lga'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    throw Exception('Failed to load contacts');
  }
}
