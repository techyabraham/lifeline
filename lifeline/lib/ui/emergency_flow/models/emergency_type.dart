// lib/ui/emergency_flow/models/emergency_type.dart
import 'package:flutter/material.dart';

class EmergencyType {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const EmergencyType({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

const List<EmergencyType> defaultEmergencyTypes = [
  EmergencyType(
      id: 'hospital',
      title: 'Hospital',
      icon: Icons.local_hospital,
      color: Colors.red),
  EmergencyType(
      id: 'police',
      title: 'Police',
      icon: Icons.local_police,
      color: Colors.blue),
  EmergencyType(
      id: 'fire',
      title: 'Fire',
      icon: Icons.local_fire_department,
      color: Colors.orange),
  EmergencyType(
      id: 'amotekun',
      title: 'Amotekun',
      icon: Icons.shield,
      color: Colors.green),
  EmergencyType(
      id: 'frsc', title: 'FRSC', icon: Icons.traffic, color: Colors.yellow),
  EmergencyType(
      id: 'my_contacts',
      title: 'My Contacts',
      icon: Icons.contacts,
      color: Colors.purple),
];
