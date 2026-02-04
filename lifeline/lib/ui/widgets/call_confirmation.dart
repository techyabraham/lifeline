// lib/ui/widgets/call_confirmation.dart
import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../services/call_service.dart';

class CallConfirmation extends StatelessWidget {
  final ContactModel contact;

  const CallConfirmation({super.key, required this.contact});

  Future<void> _makeCall(BuildContext context) async {
    await CallService.call(context, contact.phone);
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
