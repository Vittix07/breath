import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/pattern_engine.dart';

class InsightsCard extends StatelessWidget {
  final Map<String, int> contextDistribution;
  final Map<int, int> weekData;
  final int todayCount;
  final int yesterdayCount;
  final int monthCount;
  final double cigarettesPerDay;
  final int smokingYears;
  final double pricePerPack;
  final double nicotinePerUnit;
  final double tarPerUnit;
  final String productType;
  final int totalLogged;
  final List<int> dailyCounts;
  final Map<int, int> hourlyDistribution;
  final int dataDays;

  const InsightsCard({
    super.key,
    required this.contextDistribution,
    required this.weekData,
    required this.todayCount,
    required this.yesterdayCount,
    required this.monthCount,
    this.cigarettesPerDay = 10,
    this.smokingYears = 3,
    this.pricePerPack = 6.00,
    this.nicotinePerUnit = 1.2,
    this.tarPerUnit = 10.0,
    this.productType = 'cigarette',
    this.totalLogged = 0,
    this.dailyCounts = const [],
    this.hourlyDistribution = const {},
    this.dataDays = 1,
  });

  @override
  Widget build(BuildContext context) {
    final stats = UserStats(
      dataDays: dataDays,
      cigarettesPerDay: cigarettesPerDay,
      smokingYears: smokingYears,
      packYears: (cigarettesPerDay / 20) * smokingYears,
      pricePerPack: pricePerPack,
      nicotinePerUnit: nicotinePerUnit,
      tarPerUnit: tarPerUnit,
      productType: productType,
      todayCount: todayCount,
      yesterdayCount: yesterdayCount,
      monthCount: monthCount,
      weekData: weekData,
      contextDistribution: contextDistribution,
      hourlyDistribution: hourlyDistribution,
      totalLogged: totalLogged,
      dailyCounts: dailyCounts,
    );

    final insights = selectDailyInsights(stats, DateTime.now());

    return Container(
      width: double.infinity,
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.indigo.withOpacity(0.10),
          width: 1,
        ),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.indigo.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.lightbulb,
                    size: 18, color: AppColors.indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('I tuoi pattern', style: AppTextStyles.subtitle),
              ),
              Text(
                'Aggiornati oggi',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (insights.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.sky.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.sparkles,
                        size: 15, color: AppColors.sky),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Logga le sigarette per scoprire i tuoi pattern!',
                      style: AppTextStyles.body.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            )
          else
            ...insights.asMap().entries.map((entry) {
              final i = entry.key;
              final insight = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: insight.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(insight.icon, size: 15, color: insight.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: AppTextStyles.body.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 80 * i),
                    duration: 400.ms,
                  )
                  .slideX(begin: 0.03);
            }),
        ],
      ),
    );
  }
}
