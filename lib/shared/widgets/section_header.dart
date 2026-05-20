import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionHeader({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppTextStyles.label.color),
          const SizedBox(width: 8),
        ],
        Text(title, style: AppTextStyles.subtitle),
      ],
    );
  }
}
