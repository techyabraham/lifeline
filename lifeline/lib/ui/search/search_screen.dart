import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../repositories/contacts_repository.dart';
import '../../models/contact_model.dart';
import '../widgets/contact_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? selectedState;
  String? selectedLGA;
  List<String> states = [];
  List<String> lgas = [];
  List<ContactModel> contacts = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  void _loadStates() async {
    final result = await apiService.fetchStates();
    setState(() => states = result);
  }

  void _loadLGAs(String state) async {
    final result = await apiService.fetchLGAs(state);
    setState(() => lgas = result);
  }

  void _searchContacts() async {
    if (selectedLGA != null) {
      final repo = ContactsRepository(apiService: apiService);
      final result = await repo.getContacts(lga: selectedLGA!);
      setState(() => contacts = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? category = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: Text(category ?? 'Search Contacts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButton<String>(
              hint: Text('Select State'),
              value: selectedState,
              isExpanded: true,
              items: states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                setState(() {
                  selectedState = val;
                  selectedLGA = null;
                  lgas = [];
                  contacts = [];
                });
                if (val != null) _loadLGAs(val);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButton<String>(
              hint: Text('Select LGA'),
              value: selectedLGA,
              isExpanded: true,
              items: lgas.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) {
                setState(() => selectedLGA = val);
                _searchContacts();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: contacts.length,
              itemBuilder: (context, index) => ContactCard(contact: contacts[index]),
            ),
          ),
        ],
      ),
    );
  }
}
