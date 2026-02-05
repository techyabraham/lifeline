// lib/ui/emergency_flow/screens/calling_screen.dart
import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../../services/call_service.dart';

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
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CallService.call(context, widget.phone);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1220), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.08).animate(
                          CurvedAnimation(
                            parent: _pulseCtrl,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppDesignColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.soft,
                          ),
                          child: Center(
                            child: Text(
                              widget.providerName.isNotEmpty
                                  ? widget.providerName[0].toUpperCase()
                                  : 'L',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.providerName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.phone,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Calling...',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppDesignColors.danger,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.soft,
                        ),
                        child: const Icon(Icons.call_end, color: Colors.white, size: 34),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Try next provider',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
