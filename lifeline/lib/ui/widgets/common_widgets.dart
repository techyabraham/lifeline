// lib/ui/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LargeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;

  const LargeButton({
    required this.label,
    required this.onTap,
    this.color,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.brandBlue;
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: bg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
