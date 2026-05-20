import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/medical_constants.dart';
import '../../../core/theme/app_text_styles.dart';

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.shieldCheck, size: 20, color: Color(0xFFB8860B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              MedicalConstants.disclaimer,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF7A6A2E),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
