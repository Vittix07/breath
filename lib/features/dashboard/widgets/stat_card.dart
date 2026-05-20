import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/animated_number.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final String? subtitle;
  final Color accentColor;
  final String? suffix;
  final bool showHelpIcon;
  final String? helpTitle;
  final String? helpText;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.accentColor,
    this.suffix,
    this.showHelpIcon = false,
    this.helpTitle,
    this.helpText,
  });

  void _showHelp(BuildContext context) {
    if (helpTitle == null || helpText == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(helpTitle!, style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Text(
              helpText!,
              style: AppTextStyles.body.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.55, 1.0],
            colors: [
              accentColor,
              accentColor.withOpacity(0.85),
              accentColor.withOpacity(0.70),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accentColor.withOpacity(0.10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -18,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            if (showHelpIcon)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showHelp(context),
                  child: Icon(
                    LucideIcons.helpCircle,
                    size: 16,
                    color: Colors.white.withOpacity(0.60),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.75),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AnimatedNumber(
                  value: value,
                  suffix: suffix,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
