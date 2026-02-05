// lib/ui/search/search_screen.dart
import 'package:flutter/material.dart';
import '../../config/design_system.dart';
import '../../services/api_service.dart';
import '../../services/geo_data_service.dart';
import '../../repositories/contacts_repository.dart';
import '../../models/emergency_contact.dart';
import '../../models/contact_model.dart';
import '../widgets/contact_card.dart';
import '../widgets/design_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  final GeoDataService _geo = GeoDataService.instance;
  late final ContactsRepository _repo;

  int? selectedStateId;
  int? selectedLgaId;

  List<GeoState> states = [];
  List<GeoLga> lgas = [];

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

      await _geo.init();
      final fetchedStates = _geo.states;
      final fetchedLgas = _geo.states.expand((s) => s.lgas).toList();

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
  // FILTER LGAs BY STATE
  // ------------------------------------------------------------
  List<GeoLga> get _filteredLgas {
    if (selectedStateId == null) return lgas;

    final filtered = lgas.where((lga) => lga.stateId == selectedStateId).toList();

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

      // Convert EmergencyContact -> ContactModel for UI
      final mapped = result.map((c) {
        final stateName = states
            .firstWhere(
              (s) => s.id == c.state,
              orElse: () => const GeoState(
                id: -1,
                name: '',
                displayName: '',
                slug: '',
                lgas: [],
              ),
            )
            .displayName;

        final lgaName = lgas
            .firstWhere(
              (l) => l.id == c.lga,
              orElse: () => const GeoLga(
                id: -1,
                name: '',
                slug: '',
                stateId: -1,
                stateSlug: '',
              ),
            )
            .name;

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
        title: Text(category ?? 'Select Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                side: const BorderSide(color: AppDesignColors.gray200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select State',
                        filled: true,
                        fillColor: AppDesignColors.gray50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          borderSide: const BorderSide(color: AppDesignColors.gray200),
                        ),
                      ),
                      value: selectedStateId,
                      items: states
                          .map(
                            (s) => DropdownMenuItem<int>(
                              value: s.id,
                              child: Text(s.displayName),
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select LGA',
                        filled: true,
                        fillColor: AppDesignColors.gray50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          borderSide: const BorderSide(color: AppDesignColors.gray200),
                        ),
                      ),
                      value: selectedLgaId,
                      items: _filteredLgas
                          .map(
                            (l) => DropdownMenuItem<int>(
                              value: l.id,
                              child: Text(l.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedLgaId = val);
                        _searchContacts();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: loading
                  ? const LoadingState(message: 'Loading contacts...')
                  : error != null
                      ? Center(child: Text(error!))
                      : contacts.isEmpty
                          ? const Center(child: Text('No contacts found'))
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: contacts.length,
                              itemBuilder: (context, index) =>
                                  ContactCard(contact: contacts[index]),
                            ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 54,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppDesignColors.gray200),
              ),
              child: const Text('Ad goes here'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/emergency/location'),
        child: const Icon(Icons.sos),
      ),
    );
  }
}
