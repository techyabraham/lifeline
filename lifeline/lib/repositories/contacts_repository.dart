import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact_model.dart';
import '../services/api_service.dart';

class ContactsRepository {
  final ApiService apiService;
  ContactsRepository({required this.apiService});

  Future<List<ContactModel>> getContacts({required String lga}) async {
    try {
      final data = await apiService.fetchContacts(lga);
      final contacts = data.map((json) => ContactModel.fromJson(json)).toList();
      // Cache offline
      Hive.box('contacts_cache').put(lga, data);
      return contacts;
    } catch (_) {
      // fallback to cache
      final cached = Hive.box('contacts_cache').get(lga);
      if (cached != null) {
        return (cached as List).map((json) => ContactModel.fromJson(json)).toList();
      }
      rethrow;
    }
  }
}
