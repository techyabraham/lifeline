// lib/ui/emergency_flow/screens/emergency_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../flow_controller.dart';
import '../models/emergency_type.dart';

class EmergencySelectionScreen extends StatelessWidget {
  const EmergencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<EmergencyFlowController>(context);
    final lga = ctrl.selectedLga ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('What do you need?')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          if (lga.isNotEmpty)
            Card(
                child: ListTile(
                    leading: const Icon(Icons.place),
                    title: Text('Location: $lga'),
                    trailing: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Change')))),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: defaultEmergencyTypes.map((t) {
                return GestureDetector(
                  onTap: () {
                    ctrl.pickType(t);
                    Navigator.pushNamed(context, '/emergency/results');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: t.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(t.icon, size: 44, color: t.color),
                          const SizedBox(height: 12),
                          Text(t.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
