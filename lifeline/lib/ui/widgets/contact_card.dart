// lib/ui/widgets/contact_card.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/contact_model.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;

  const ContactCard({
    super.key,
    required this.contact,
  });

  // ------------------------------------------------------------
  // ACTIONS
  // ------------------------------------------------------------

  void _shareContact() {
    final message = '${contact.agency} (${contact.category})\n'
        'Phone: ${contact.phone}\n'
        'LGA: ${contact.lga}, State: ${contact.state}';

    Share.share(message);
  }

  Future<void> _callNow(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to place call')),
      );
    }
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (contact.category.toLowerCase()) {
      case 'police':
        color = Colors.blue;
        break;
      case 'fire':
      case 'fire service':
        color = Colors.red;
        break;
      case 'health':
      case 'hospital':
        color = Colors.green;
        break;
      case 'frsc':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.local_phone, color: color),
        title: Text(
          contact.agency,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${contact.lga}, ${contact.state}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Share',
              onPressed: _shareContact,
              icon: const Icon(Icons.share),
            ),
            IconButton(
              tooltip: 'Call now',
              onPressed: () => _callNow(context),
              icon: Icon(Icons.call, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
