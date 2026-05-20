import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/lung_score_calculator.dart';
import '../../../core/utils/cost_calculator.dart';
import '../../../core/utils/nicotine_calculator.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/log_provider.dart';
import '../widgets/lung_score_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/money_tracker_card.dart';
import '../widgets/tar_tracker_card.dart';
import '../widgets/insights_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final todayLogs = ref.watch(todayLogsProvider);
    final yesterdayLogs = ref.watch(yesterdayLogsProvider);
    final weekData = ref.watch(weekLogsProvider);
    final monthLogs = ref.watch(monthLogsProvider);
    final contextDist = ref.watch(contextDistributionProvider);
    final dailyCounts = ref.watch(dailyCountsProvider);
    final hourlyDist = ref.watch(hourlyDistributionProvider);
    final dataDays = ref.watch(dataDaysProvider);
    final allLogs = ref.watch(cigaretteLogsProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    if (profile == null) return const SizedBox.shrink();

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

    final diff = todayLogs.length - yesterdayLogs.length;
    final diffText = diff == 0
        ? 'come ieri'
        : diff > 0
            ? '+$diff vs ieri'
            : '$diff vs ieri';

    final packPrice = profile.effectivePackPrice;
    final moneySpent = CostCalculator.moneySpent(
      cigaretteCount: monthLogs.length,
      packSize: 20,
      packPrice: packPrice,
    );
    final cigsInPack = CostCalculator.cigarettesInCurrentPack(
      cigaretteCount: monthLogs.length,
      packSize: 20,
    );

    final tarGrams = NicotineCalculator.tarInhaledGrams(
      monthLogs.length,
      profile.effectiveTarMg,
    );
    final isHeated =
        profile.productType == 'iqos' && profile.effectiveTarMg == 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ciao!', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 2),
                  Text('Come va oggi?', style: AppTextStyles.titleLarge),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.bell,
                    size: 20, color: AppColors.primary),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          LungScoreCard(
            score: lungScore,
            onTap: () => context.go('/report'),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),
          const SizedBox(height: 14),
          Row(
            children: [
              StatCard(
                icon: LucideIcons.flame,
                label: 'Oggi',
                value: todayLogs.length,
                subtitle: diffText,
                accentColor: AppColors.rose,
              ),
              const SizedBox(width: 14),
              StatCard(
                icon: LucideIcons.activity,
                label: 'Pack-years',
                value: packYrs.round(),
                accentColor: AppColors.cyan,
                showHelpIcon: true,
                helpTitle: 'Cosa sono i pack-years?',
                helpText:
                    'I pack-years misurano la tua esposizione totale al fumo. '
                    '1 pack-year equivale a fumare 20 sigarette al giorno per 1 anno. '
                    'E la metrica che usano i medici per valutare il rischio polmonare.',
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(begin: 0.05),
          const SizedBox(height: 14),
          WeeklyChart(data: weekData)
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.05),
          const SizedBox(height: 14),
          Row(
            children: [
              MoneyTrackerCard(
                amountSpent: moneySpent,
                cigarettesInCurrentPack: cigsInPack,
                packSize: 20,
              ),
              const SizedBox(width: 14),
              TarTrackerCard(
                tarGrams: tarGrams,
                isHeatedProduct: isHeated,
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideY(begin: 0.05),
          const SizedBox(height: 14),
          InsightsCard(
            contextDistribution: contextDist,
            weekData: weekData,
            todayCount: todayLogs.length,
            yesterdayCount: yesterdayLogs.length,
            monthCount: monthLogs.length,
            cigarettesPerDay: profile.cigarettesPerDay,
            smokingYears: profile.smokingYears,
            pricePerPack: packPrice,
            nicotinePerUnit: profile.effectiveNicotineMg,
            tarPerUnit: profile.effectiveTarMg,
            productType: profile.productType,
            totalLogged: allLogs.length,
            dailyCounts: dailyCounts,
            hourlyDistribution: hourlyDist,
            dataDays: dataDays,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.05),
        ],
      ),
    );
  }
}
