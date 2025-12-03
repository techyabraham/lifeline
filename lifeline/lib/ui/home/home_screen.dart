import 'package:flutter/material.dart';
import '../widgets/category_button.dart';
import '../widgets/sos_button.dart';
import '../widgets/contact_card.dart';
import '../../models/contact_model.dart';
import '../../services/api_service.dart';
import '../../repositories/contacts_repository.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ContactsRepository contactsRepo;
  List<ContactModel> topContacts = [];
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    contactsRepo = ContactsRepository(apiService: ApiService());
    _loadContacts();
    _loadAd();
  }

  void _loadContacts() async {
    try {
      final contacts =
          await contactsRepo.getContacts(lga: 'Ikeja'); // async gap
      if (!mounted) return; // Check if widget is still in tree
      setState(() => topContacts = contacts.take(5).toList());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load contacts')));
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: '<YOUR_BANNER_AD_UNIT>',
      size: AdSize.banner,
      listener: BannerAdListener(),
      request: AdRequest(),
    )..load();
  }

  void _onSOSPressed() {
    if (!mounted) return; // Ensure widget still exists
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Emergency SOS Activated'),
        content: Text('Your emergency contacts will be called shortly'),
        actions: [
          TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Police', 'icon': Icons.local_police, 'color': Colors.blue},
      {
        'title': 'Fire',
        'icon': Icons.local_fire_department,
        'color': Colors.red
      },
      {'title': 'Health', 'icon': Icons.local_hospital, 'color': Colors.green},
      {'title': 'FRSC', 'icon': Icons.traffic, 'color': Colors.yellow.shade700},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('LifeLine')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(12),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: categories
                  .map((cat) => CategoryButton(
                        title: cat['title'] as String,
                        icon: cat['icon'] as IconData,
                        color: cat['color'] as Color,
                        onTap: () => Navigator.pushNamed(context, '/search',
                            arguments: cat['title']),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: topContacts.length,
              itemBuilder: (context, index) =>
                  ContactCard(contact: topContacts[index]),
            ),
          ),
          if (_bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton:
          SosButton(color: Colors.red, onPressed: _onSOSPressed),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
