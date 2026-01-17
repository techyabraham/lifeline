// lib/ui/emergency_flow/screens/emergency_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../flow_controller.dart';
import '../models/emergency_type.dart';
import '../widgets/common_widgets.dart';

class EmergencySelectionScreen extends StatelessWidget {
  const EmergencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final lga = ctrl.selectedLga ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Area')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (lga.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.place, color: AppColors.brandBlue),
                  title: Text('Current Location: $lga'),
                  trailing: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Change'),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What do you need?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: defaultEmergencyTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = defaultEmergencyTypes[index];
                  return BigActionButton(
                    label: t.title,
                    subtitle: 'Tap to see nearest providers',
                    icon: t.icon,
                    color: t.color,
                    onTap: () {
                      ctrl.pickType(t);
                      Navigator.pushNamed(context, '/emergency/results');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/emergency/location'),
        child: const Icon(Icons.sos),
      ),
    );
  }
}
