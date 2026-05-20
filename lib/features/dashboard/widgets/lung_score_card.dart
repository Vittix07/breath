import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/lung_score_calculator.dart';
import '../../../shared/widgets/lung_fill_visual.dart';
import '../../../shared/widgets/animated_number.dart';

class LungScoreCard extends StatelessWidget {
  final int score;
  final VoidCallback? onTap;

  const LungScoreCard({super.key, required this.score, this.onTap});

  List<Color> get _liquidColors {
    if (score >= 75) {
      return [const Color(0xFF6EE7B7), const Color(0xFF10B981)];
    } else if (score >= 50) {
      return [const Color(0xFFFDE68A), const Color(0xFFF59E0B)];
    } else {
      return [const Color(0xFFFCA5A5), const Color(0xFFEF4444)];
    }
  }

  Color get _scoreColor {
    if (score >= 90) return const Color(0xFF10B981);
    if (score >= 75) return const Color(0xFF22C55E);
    if (score >= 60) return const Color(0xFFF59E0B);
    if (score >= 40) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  IconData get _moodIcon {
    if (score >= 90) return LucideIcons.smile;
    if (score >= 75) return LucideIcons.smile;
    if (score >= 60) return LucideIcons.meh;
    if (score >= 40) return LucideIcons.frown;
    return LucideIcons.frown;
  }

  @override
  Widget build(BuildContext context) {
    final (label, _) = LungScoreCalculator.scoreLabel(score);
    final displayColor = _scoreColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 18, 20, 18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: displayColor.withOpacity(0.10),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: displayColor.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            ...AppDimensions.cardShadow,
          ],
        ),
        child: Row(
          children: [
            LungFillVisual(
              fillLevel: score / 100,
              liquidColor: displayColor,
              gradientColors: _liquidColors,
              width: 135,
              height: 148,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LUNG SCORE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedNumber(
                        value: score,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: displayColor,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: displayColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_moodIcon, size: 14, color: displayColor),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: displayColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Capacita polmonare\nstimata vs non fumatore',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Vedi report',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.arrowRight,
                          size: 14, color: AppColors.primary),
                    ],
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
