import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;

  const ContactCard({Key? key, required this.contact}) : super(key: key);

  void _callNumber(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _shareContact() {
    Share.share('${contact.agency} (${contact.category})\nPhone: ${contact.phone}\nLocation: ${contact.lga}, ${contact.state}');
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (contact.category.toLowerCase()) {
      case 'police':
        color = Colors.blue;
        break;
      case 'fire':
        color = Colors.red;
        break;
      case 'health':
        color = Colors.green;
        break;
      case 'frsc':
        color = Colors.yellow.shade700;
        break;
      default:
        color = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.local_phone, color: color),
        title: Text(contact.agency),
        subtitle: Text(contact.lga),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: _shareContact, icon: Icon(Icons.share)),
            IconButton(onPressed: () => _callNumber(contact.phone), icon: Icon(Icons.call, color: color)),
          ],
        ),
      ),
    );
  }
}
