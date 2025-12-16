// lib/repositories/contacts_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/emergency_contact.dart';
import '../services/api_service.dart';

class ContactsRepository {
  final ApiService apiService;

  ContactsRepository({required this.apiService});

  /// ---------------------------------------------------
  /// MAIN FETCH METHOD
  /// Used by:
  /// - SearchScreen
  /// - Emergency Results Screen
  /// ---------------------------------------------------
  Future<List<EmergencyContact>> getContacts({
    int? categoryId,
    int? stateId,
    int? lgaId,
  }) async {
    final cacheKey =
        'contacts_${categoryId ?? 0}_${stateId ?? 0}_${lgaId ?? 0}';

    final box = Hive.box('contacts_cache');

    try {
      final contacts = await apiService.fetchContacts(
        serviceCategoryId: categoryId,
        stateId: stateId,
        lgaId: lgaId,
      );

      // Cache raw JSON-compatible maps
      final cachedPayload = contacts.map((c) => _toCacheJson(c)).toList();
      await box.put(cacheKey, cachedPayload);

      return contacts;
    } catch (e) {
      // Fallback to cache
      final cached = box.get(cacheKey);
      if (cached != null && cached is List) {
        return cached
            .map((e) => EmergencyContact.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      }
      rethrow;
    }
  }

  /// ---------------------------------------------------
  /// SINGLE CONTACT (optional helper)
  /// ---------------------------------------------------
  Future<EmergencyContact?> getContactById(int id) async {
    final cacheKey = 'contact_$id';
    final box = Hive.box('contacts_cache');

    try {
      final contact = await apiService.fetchSingle(id);
      await box.put(cacheKey, _toCacheJson(contact));
      return contact;
    } catch (_) {
      final cached = box.get(cacheKey);
      if (cached != null) {
        return EmergencyContact.fromJson(
          Map<String, dynamic>.from(cached),
        );
      }
      return null;
    }
  }

  // ---------------------------------------------------
  // INTERNAL: Convert model → WP-like JSON for cache
  // ---------------------------------------------------
  Map<String, dynamic> _toCacheJson(EmergencyContact c) {
    return {
      'id': c.id,
      'title': {'rendered': c.name},
      'acf': {
        'phone_number': c.phoneNumber,
        'secondary_phone': c.secondaryPhone,
        'address': c.address,
        'latitude': c.latitude,
        'longitude': c.longitude,
        'is_verified': c.isVerified,
      },
      'service_category': c.serviceCategories,
      'state': c.state != null ? [c.state] : [],
      'lga': c.lga != null ? [c.lga] : [],
    };
  }
}
