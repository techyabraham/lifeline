// lib/ui/emergency_flow/models/emergency_type.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';

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
      color: AppColors.brandRed),
  EmergencyType(
      id: 'police',
      title: 'Police',
      icon: Icons.local_police,
      color: AppColors.brandBlue),
  EmergencyType(
      id: 'fire',
      title: 'Fire',
      icon: Icons.local_fire_department,
      color: AppColors.brandOrange),
  EmergencyType(
      id: 'amotekun',
      title: 'Amotekun',
      icon: Icons.shield,
      color: AppColors.brandGreen),
  EmergencyType(
      id: 'frsc',
      title: 'FRSC',
      icon: Icons.traffic,
      color: AppColors.brandOrange),
  EmergencyType(
      id: 'my_contacts',
      title: 'My Contacts',
      icon: Icons.contacts,
      color: AppColors.navy),
];
