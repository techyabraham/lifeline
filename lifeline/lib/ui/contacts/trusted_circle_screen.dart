// lib/ui/contacts/trusted_circle_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/design_system.dart';
import '../../models/trusted_contact.dart';
import '../widgets/design_widgets.dart';

class TrustedCircleScreen extends StatefulWidget {
  const TrustedCircleScreen({super.key});

  @override
  State<TrustedCircleScreen> createState() => _TrustedCircleScreenState();
}

class _TrustedCircleScreenState extends State<TrustedCircleScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _relationship = 'Friend';
  bool _isPriority = false;
  String? _editingId;

  static const List<String> _relationships = [
    'Parent',
    'Sibling',
    'Spouse',
    'Child',
    'Friend',
    'Neighbor',
    'Colleague',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _startAdd() {
    setState(() {
      _editingId = null;
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _relationship = 'Friend';
      _isPriority = false;
    });
  }

  void _startEdit(TrustedContact contact) {
    setState(() {
      _editingId = contact.id;
      _nameCtrl.text = contact.name;
      _phoneCtrl.text = contact.phone;
      _relationship = contact.relationship;
      _isPriority = contact.isPriority;
    });
  }

  void _saveContact() {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final box = Hive.box('trusted_contacts');
    final id = _editingId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final contact = TrustedContact(
      id: id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      relationship: _relationship,
      isPriority: _isPriority,
    );

    box.put(id, contact.toMap());

    setState(() {
      _editingId = null;
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _relationship = 'Friend';
      _isPriority = false;
    });
  }

  Future<void> _callContact(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _smsContact(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('trusted_contacts');

    return Scaffold(
      backgroundColor: AppDesignColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text('Your Trusted Circle', style: AppTextStyles.h2),
                  ),
                  IconButton(
                    onPressed: _startAdd,
                    icon: const Icon(Icons.add_circle, color: AppDesignColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.people, color: AppDesignColors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'These contacts will be notified during emergencies with your location.',
                            style: TextStyle(fontSize: 12, color: AppDesignColors.gray700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Import from contacts',
                    icon: Icons.contact_phone,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('TODO: Import from contacts')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingId == null ? 'Add Contact' : 'Edit Contact',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Full name',
                            filled: true,
                            fillColor: AppDesignColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              borderSide: const BorderSide(color: AppDesignColors.gray200),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone number',
                            filled: true,
                            fillColor: AppDesignColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              borderSide: const BorderSide(color: AppDesignColors.gray200),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _relationship,
                          decoration: InputDecoration(
                            labelText: 'Relationship',
                            filled: true,
                            fillColor: AppDesignColors.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              borderSide: const BorderSide(color: AppDesignColors.gray200),
                            ),
                          ),
                          items: _relationships
                              .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _relationship = v ?? 'Friend'),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => setState(() => _isPriority = !_isPriority),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppDesignColors.gray50,
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isPriority ? Icons.star : Icons.star_border,
                                  color: _isPriority
                                      ? AppDesignColors.warning
                                      : AppDesignColors.gray400,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text('Priority Contact'),
                                ),
                                Switch(
                                  value: _isPriority,
                                  onChanged: (v) => setState(() => _isPriority = v),
                                  activeColor: AppDesignColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Cancel',
                                onPressed: _startAdd,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PrimaryButton(
                                label: _editingId == null ? 'Add Contact' : 'Update',
                                onPressed: _saveContact,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (context, Box<dynamic> value, _) {
                      final contacts = value.values
                          .map((e) => TrustedContact.fromMap(Map<String, dynamic>.from(e)))
                          .toList();

                      if (contacts.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.people_outline, size: 40, color: AppDesignColors.gray300),
                              SizedBox(height: 8),
                              Text('No trusted contacts yet'),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: contacts.map((contact) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              boxShadow: AppShadows.subtle,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(contact.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    if (contact.isPriority)
                                      const PillBadge(
                                        label: 'Priority',
                                        background: Color(0x1AFFCC00),
                                        foreground: AppDesignColors.warning,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(contact.phone,
                                    style: AppTextStyles.bodyMuted),
                                const SizedBox(height: 6),
                                PillBadge(
                                  label: contact.relationship,
                                  background: const Color(0x1A0047AB),
                                  foreground: AppDesignColors.primary,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        label: 'Call',
                                        icon: Icons.call,
                                        onPressed: () => _callContact(contact.phone),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _smsContact(contact.phone),
                                      icon: const Icon(Icons.sms),
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppDesignColors.gray100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppRadii.md),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      onPressed: () => _startEdit(contact),
                                      icon: const Icon(Icons.edit),
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppDesignColors.gray100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppRadii.md),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      onPressed: () => box.delete(contact.id),
                                      icon: const Icon(Icons.delete, color: AppDesignColors.danger),
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppDesignColors.gray100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppRadii.md),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
