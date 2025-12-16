// lib/ui/emergency_flow/screens/calling_screen.dart
import 'package:flutter/material.dart';

class EmergencyCallingScreen extends StatefulWidget {
  final String providerName;
  final String phone;

  const EmergencyCallingScreen({
    super.key,
    required this.providerName,
    required this.phone,
  });

  @override
  State<EmergencyCallingScreen> createState() => _EmergencyCallingScreenState();
}

class _EmergencyCallingScreenState extends State<EmergencyCallingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = Colors.greenAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing animation
              ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.10).animate(
                  CurvedAnimation(
                    parent: _pulseCtrl,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.15),
                  ),
                  child: Icon(
                    Icons.phone_in_talk,
                    color: accent,
                    size: 90,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Calling text
              const Text(
                "Calling...",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 8),

              // Provider name
              Text(
                widget.providerName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              // Phone number
              Text(
                widget.phone,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 40),

              // Cancel call button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.call_end),
                label: const Text(
                  "Cancel Call",
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 18),

              // Try next provider
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close calling
                  Navigator.pop(context); // Back to results
                },
                child: const Text(
                  "Try next provider",
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
