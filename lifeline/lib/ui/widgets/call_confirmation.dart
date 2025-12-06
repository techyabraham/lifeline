// lib/ui/widgets/call_confirmation.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contact_model.dart';

class CallConfirmation extends StatelessWidget {
  final ContactModel contact;

  const CallConfirmation({super.key, required this.contact});

  Future<void> _makeCall(BuildContext context) async {
    final Uri callUri = Uri(scheme: 'tel', path: contact.phone);
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        // Use ScaffoldMessenger only if context is still valid
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make the call')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Call ${contact.agency}?'),
      content: Text('Do you want to call ${contact.phone}?'),
      actions: [
        TextButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.blue, // use backgroundColor instead of primary
          ),
          onPressed: () async {
            await _makeCall(context);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('Call'),
        ),
      ],
    );
  }
}
