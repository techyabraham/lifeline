// lib/ui/search/search_screen.dart
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../repositories/contacts_repository.dart';
import '../../models/emergency_contact.dart';
import '../../models/contact_model.dart';
import '../widgets/contact_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  late final ContactsRepository _repo;

  int? selectedStateId;
  int? selectedLgaId;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> lgas = [];

  List<ContactModel> contacts = [];
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _repo = ContactsRepository(apiService: _api);
    _loadStatesAndLGAs();
  }

  // ------------------------------------------------------------
  // LOAD STATES & LGAS
  // ------------------------------------------------------------
  Future<void> _loadStatesAndLGAs() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final fetchedStates = await _api.fetchStates();
      final fetchedLgas = await _api.fetchLgas();

      setState(() {
        states = fetchedStates;
        lgas = fetchedLgas;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Failed to load states and LGAs';
      });
    }
  }

  // ------------------------------------------------------------
  // FILTER LGAs BY STATE (if parent relationship exists)
  // ------------------------------------------------------------
  List<Map<String, dynamic>> get _filteredLgas {
    if (selectedStateId == null) return lgas;

    final filtered =
        lgas.where((lga) => lga['parent'] == selectedStateId).toList();

    return filtered.isNotEmpty ? filtered : lgas;
  }

  // ------------------------------------------------------------
  // SEARCH CONTACTS
  // ------------------------------------------------------------
  Future<void> _searchContacts() async {
    if (selectedLgaId == null) return;

    try {
      setState(() {
        loading = true;
        error = null;
        contacts = [];
      });

      final List<EmergencyContact> result = await _repo.getContacts(
          stateId: selectedStateId, lgaId: selectedLgaId);

      // Convert EmergencyContact → ContactModel for UI
      final mapped = result.map((c) {
        final stateName = states.firstWhere(
          (s) => s['id'] == c.state,
          orElse: () => {},
        )['name'];

        final lgaName = lgas.firstWhere(
          (l) => l['id'] == c.lga,
          orElse: () => {},
        )['name'];

        return ContactModel.fromEmergency(
          c,
          stateName: stateName,
          lgaName: lgaName,
        );
      }).toList();

      setState(() {
        contacts = mapped;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Failed to load contacts';
      });
    }
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final String? category =
        ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text(category ?? 'Search Emergency Contacts'),
      ),
      body: Column(
        children: [
          // STATE DROPDOWN
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select State'),
              value: selectedStateId,
              items: states
                  .map(
                    (s) => DropdownMenuItem<int>(
                      value: s['id'],
                      child: Text(s['name']),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedStateId = val;
                  selectedLgaId = null;
                  contacts = [];
                });
              },
            ),
          ),

          // LGA DROPDOWN
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select LGA'),
              value: selectedLgaId,
              items: _filteredLgas
                  .map(
                    (l) => DropdownMenuItem<int>(
                      value: l['id'],
                      child: Text(l['name']),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() => selectedLgaId = val);
                _searchContacts();
              },
            ),
          ),

          // RESULTS
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : contacts.isEmpty
                        ? const Center(child: Text('No contacts found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: contacts.length,
                            itemBuilder: (context, index) =>
                                ContactCard(contact: contacts[index]),
                          ),
          ),
        ],
      ),
    );
  }
}
