import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showCallConfirmation(BuildContext context, String agency, String phone, Color color) async {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Call $agency?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: color),
          onPressed: () async {
            final Uri url = Uri(scheme: 'tel', path: phone);
            if (await canLaunchUrl(url)) await launchUrl(url);
            Navigator.pop(ctx);
          },
          child: Text('Call'),
        ),
      ],
    ),
  );
}
