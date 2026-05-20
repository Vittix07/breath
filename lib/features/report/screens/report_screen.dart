import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/lung_score_calculator.dart';
import '../../../core/utils/cost_calculator.dart';
import '../../../core/utils/nicotine_calculator.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/log_provider.dart';
import '../../../shared/widgets/lung_fill_visual.dart';
import '../../../shared/widgets/animated_number.dart';
import '../../../shared/widgets/breath_card.dart';
import '../widgets/projection_chart.dart';
import '../widgets/disclaimer_card.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    if (profile == null) return const SizedBox.shrink();

    final monthLogs = ref.watch(monthLogsProvider);

    final modifierFactor = LungScoreCalculator.computeModifierFactor(
      exerciseLevel: profile.exerciseLevel,
      ageFirstCigarette: profile.ageFirstCigarette,
      productType: profile.productType,
      fagerstromScore: profile.fagerstromScore,
      baselineCough: profile.baselineCough,
      baselineBreathlessness: profile.baselineBreathlessness,
    );

    final lungScore = LungScoreCalculator.calculate(
      age: profile.age,
      sex: profile.biologicalSex,
      heightCm: profile.heightCm,
      smokingYears: profile.smokingYears,
      cigarettesPerDay: profile.cigarettesPerDay,
      modifierFactor: modifierFactor,
    );

    final packYrs = LungScoreCalculator.packYears(
      profile.cigarettesPerDay,
      profile.smokingYears,
    );

    final declinePercent = 100 - lungScore;

    final packPrice = profile.effectivePackPrice;
    final moneySpent = CostCalculator.moneySpent(
      cigaretteCount: monthLogs.length,
      packSize: 20,
      packPrice: packPrice,
    );

    final tarGrams = NicotineCalculator.tarInhaledGrams(
      monthLogs.length,
      profile.effectiveTarMg,
    );

    final dailyAvg = monthLogs.isEmpty
        ? 0.0
        : monthLogs.length / DateTime.now().day;

    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report', style: AppTextStyles.titleLarge)
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          BreathCard(
            backgroundColor: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LUNG SCORE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: LungFillVisual(
                    fillLevel: lungScore / 100,
                    liquidColor: Colors.white,
                    width: 140,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedNumber(
                        value: lungScore,
                        style: AppTextStyles.statNumber.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Un non fumatore della tua eta ha in media una capacita '
                    'polmonare del 100%. Con il tuo profilo (${packYrs.toStringAsFixed(1)} '
                    'pack-years) il modello stima un declino del ~$declinePercent%.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),
          const SizedBox(height: 20),
          BreathCard(
            child: ProjectionChart(
              currentAge: profile.age,
              sex: profile.biologicalSex,
              heightCm: profile.heightCm,
              smokingYears: profile.smokingYears,
              cigarettesPerDay: profile.cigarettesPerDay,
              modifierFactor: modifierFactor,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(begin: 0.05),
          const SizedBox(height: 20),
          Text('Riepilogo mensile', style: AppTextStyles.subtitle)
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: LucideIcons.cigarette,
            label: 'Sigarette questo mese',
            value: '${monthLogs.length}',
            color: AppColors.rose,
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.03),
          _SummaryRow(
            icon: LucideIcons.barChart3,
            label: 'Media giornaliera',
            value: '${dailyAvg.toStringAsFixed(1)}/giorno',
            color: AppColors.sky,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.03),
          _SummaryRow(
            icon: LucideIcons.activity,
            label: 'Pack-years totali',
            value: packYrs.toStringAsFixed(1),
            color: AppColors.orange,
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.03),
          _SummaryRow(
            icon: LucideIcons.coins,
            label: 'Spesa del mese',
            value: '${moneySpent.toStringAsFixed(0)}€',
            color: AppColors.amber,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.03),
          _SummaryRow(
            icon: LucideIcons.droplets,
            label: 'Catrame inalato',
            value: '${tarGrams.toStringAsFixed(2)} g',
            color: AppColors.violet,
          )
              .animate()
              .fadeIn(delay: 450.ms, duration: 400.ms)
              .slideY(begin: 0.03),
          const SizedBox(height: 24),
          const DisclaimerCard()
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: AppTextStyles.body),
          ),
          Text(
            value,
            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
