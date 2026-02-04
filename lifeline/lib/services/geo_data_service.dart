// lib/services/geo_data_service.dart
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class GeoLga {
  final int id;
  final String name;
  final String slug;
  final int stateId;
  final String stateSlug;

  const GeoLga({
    required this.id,
    required this.name,
    required this.slug,
    required this.stateId,
    required this.stateSlug,
  });
}

class GeoState {
  final int id;
  final String name;
  final String displayName;
  final String slug;
  final List<GeoLga> lgas;

  const GeoState({
    required this.id,
    required this.name,
    required this.displayName,
    required this.slug,
    required this.lgas,
  });
}

class GeoDataService {
  static final GeoDataService instance = GeoDataService._();
  GeoDataService._();

  bool _initialized = false;
  final List<GeoState> _states = [];

  List<GeoState> get states => List.unmodifiable(_states);

  Future<void> init() async {
    if (_initialized) return;

    final raw = await rootBundle.loadString('assets/data/nigeria_states_lgas.json');
    final decoded = json.decode(raw);

    final List<dynamic> stateList;
    if (decoded is Map && decoded['states'] is List) {
      stateList = decoded['states'] as List<dynamic>;
    } else if (decoded is List) {
      stateList = decoded;
    } else {
      throw StateError('Unexpected geo dataset format');
    }

    final List<GeoState> parsed = [];
    for (final dynamic entry in stateList) {
      if (entry is! Map) continue;
      final id = (entry['id'] as num).toInt();
      final name = (entry['name'] ?? '').toString();
      final slug = (entry['slug'] ?? '').toString();
      final rawDisplay = (entry['display_name'] ?? name).toString();
      final displayName = _ensureStateSuffix(rawDisplay.isNotEmpty ? rawDisplay : name);

      final List<GeoLga> lgas = [];
      final List<dynamic> lgaList = (entry['lgas'] as List<dynamic>? ?? const []);
      for (final dynamic lga in lgaList) {
        if (lga is! Map) continue;
        lgas.add(GeoLga(
          id: (lga['id'] as num).toInt(),
          name: (lga['name'] ?? '').toString(),
          slug: (lga['slug'] ?? '').toString(),
          stateId: id,
          stateSlug: slug,
        ));
      }

      parsed.add(GeoState(
        id: id,
        name: name,
        displayName: displayName,
        slug: slug,
        lgas: lgas,
      ));
    }

    _states
      ..clear()
      ..addAll(parsed);

    _initialized = true;
  }

  List<GeoLga> lgasForState(int stateId) {
    final state = _states.firstWhere(
      (s) => s.id == stateId,
      orElse: () => const GeoState(
        id: -1,
        name: '',
        displayName: '',
        slug: '',
        lgas: [],
      ),
    );
    return List.unmodifiable(state.lgas);
  }

  GeoState? matchStateByName(String input) {
    final query = _normalizeStateName(input);
    if (query.isEmpty) return null;

    if (_isFctQuery(query)) {
      for (final state in _states) {
        final norm = _normalizeStateName(state.name);
        if (norm.contains('federal capital territory') || state.slug == 'fct') {
          return state;
        }
      }
      return null;
    }

    final exact = _states.where((s) => _normalizeStateName(s.name) == query).toList();
    if (exact.isNotEmpty) return exact.first;

    final contains = _states.where((s) {
      final norm = _normalizeStateName(s.name);
      return norm.contains(query) || query.contains(norm);
    }).toList();

    return contains.isNotEmpty ? contains.first : null;
  }

  GeoLga? matchLgaByName(int? stateId, String input) {
    final query = _normalize(input);
    if (query.isEmpty) return null;

    Iterable<GeoLga> candidates;
    if (stateId != null) {
      candidates = lgasForState(stateId);
    } else {
      candidates = _states.expand((s) => s.lgas);
    }

    GeoLga? exact;
    GeoLga? contains;
    for (final lga in candidates) {
      final norm = _normalize(lga.name);
      if (norm == query) {
        exact = lga;
        break;
      }
      if (contains == null && (norm.contains(query) || query.contains(norm))) {
        contains = lga;
      }
    }

    return exact ?? contains;
  }

  static bool _isFctQuery(String normalized) {
    return normalized == 'fct' ||
        normalized.contains('abuja') ||
        normalized.contains('federal capital territory');
  }

  static String _ensureStateSuffix(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    final lower = trimmed.toLowerCase();
    return lower.endsWith('state') ? trimmed : '$trimmed State';
  }

  static String _normalizeStateName(String input) {
    final normalized = _normalize(input);
    if (normalized.endsWith(' state')) {
      return normalized.substring(0, normalized.length - ' state'.length).trim();
    }
    return normalized;
  }

  static String _normalize(String input) {
    final lower = input.toLowerCase();
    final stripped = lower.replaceAll(RegExp(r"[^a-z0-9]+"), ' ');
    return stripped.replaceAll(RegExp(r"\s+"), ' ').trim();
  }
}
