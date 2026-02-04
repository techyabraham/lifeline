// lib/ui/emergency_flow/models/emergency_type.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class EmergencyType {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final bool isPersonal;

  const EmergencyType({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.description = '',
    this.isPersonal = false,
  });
}

const List<EmergencyType> defaultEmergencyTypes = [
  EmergencyType(
      id: 'medical',
      title: 'Medical',
      icon: Icons.local_hospital,
      color: Color(0xFFE11D48),
      description: 'Hospital, Ambulance'),
  EmergencyType(
      id: 'police',
      title: 'Police',
      icon: Icons.shield_rounded,
      color: Color(0xFF1D4ED8),
      description: 'Crime, Theft'),
  EmergencyType(
      id: 'fire',
      title: 'Fire',
      icon: Icons.local_fire_department,
      color: Color(0xFFEA580C),
      description: 'Fire, Gas leak'),
  EmergencyType(
      id: 'amotekun',
      title: 'Amotekun',
      icon: Icons.security,
      color: Color(0xFF15803D),
      description: 'Local Security'),
  EmergencyType(
      id: 'road',
      title: 'Road',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFB45309),
      description: 'FRSC, Accident'),
  EmergencyType(
      id: 'mental_health',
      title: 'Mental Health',
      icon: Icons.favorite,
      color: Color(0xFF7C3AED),
      description: 'Crisis Support'),
  EmergencyType(
      id: 'my_contacts',
      title: 'My Contacts',
      icon: Icons.people,
      color: Color(0xFFEC4899),
      description: 'Call Family/Friends',
      isPersonal: true),
];
