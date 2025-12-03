// lib/ui/widgets/contact_card.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // use public API
import '../../models/contact_model.dart';
import '../widgets/call_confirmation.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;

  const ContactCard({Key? key, required this.contact}) : super(key: key);

  void _shareContact() {
    final message =
        '${contact.agency} (${contact.category})\nPhone: ${contact.phone}\nLGA: ${contact.lga}, State: ${contact.state}';
    // Use Share.share which accepts a String message
    Share.share(message);
  }

  void _confirmCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CallConfirmation(contact: contact),
    );
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
        subtitle: Text('${contact.lga}, ${contact.state}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _shareContact,
              icon: Icon(Icons.share),
              tooltip: 'Share',
            ),
            IconButton(
              onPressed: () => _confirmCall(context),
              icon: Icon(Icons.call, color: color),
              tooltip: 'Call',
            ),
          ],
        ),
      ),
    );
  }
}
