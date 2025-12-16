import 'package:flutter/material.dart';

class CallingScreen extends StatelessWidget {
  final String providerName;
  final String phone;

  const CallingScreen({
    super.key,
    required this.providerName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_in_talk, size: 90, color: Colors.greenAccent),
            const SizedBox(height: 20),
            Text(
              "Calling $providerName…",
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              phone,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel Call"),
            )
          ],
        ),
      ),
    );
  }
}
