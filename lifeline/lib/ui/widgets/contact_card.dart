// lib/ui/widgets/contact_card.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/design_system.dart';
import 'design_widgets.dart';
import '../../models/contact_model.dart';
import '../../services/call_service.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;

  const ContactCard({
    super.key,
    required this.contact,
  });

  void _shareContact() {
    final message = '${contact.agency} (${contact.category})\n'
        'Phone: ${contact.phone}\n'
        'LGA: ${contact.lga}, State: ${contact.state}';

    Share.share(message);
  }

  Future<void> _callNow(BuildContext context) async {
    await CallService.call(context, contact.phone);
  }

  Color _accentColor() {
    final key = contact.category.toLowerCase();
    if (key.contains('police')) return AppDesignColors.primary;
    if (key.contains('fire')) return AppDesignColors.danger;
    if (key.contains('health') || key.contains('hospital')) {
      return AppDesignColors.success;
    }
    if (key.contains('frsc') || key.contains('road')) {
      return AppDesignColors.warning;
    }
    return AppDesignColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();

    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_phone, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.agency,
                            style: AppTextStyles.h3,
                          ),
                        ),
                        if (contact.verified)
                          const PillBadge(
                            label: 'Verified',
                            background: Color(0x1A34C759),
                            foreground: AppDesignColors.success,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${contact.lga}, ${contact.state}',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callNow(context),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _shareContact,
                icon: const Icon(Icons.share),
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
  }
}
