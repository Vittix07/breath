import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

class WeeklyChart extends StatelessWidget {
  final Map<int, int> data;

  const WeeklyChart({super.key, required this.data});

  static const _dayLabels = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
  static const _dayFull = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday - 1;
    final maxVal = data.values.fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = maxVal < 5 ? 8.0 : (maxVal * 1.3).ceilToDouble();

    final totalWeek = data.values.fold<int>(0, (a, b) => a + b);
    final avgDaily = totalWeek > 0 ? (totalWeek / 7).toStringAsFixed(1) : '0';

    return Container(
      padding: AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Settimana', style: AppTextStyles.subtitle),
              Row(
                children: [
                  Text(
                    '$totalWeek totali',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$avgDaily/g',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 10,
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_dayFull[group.x]}: ${rod.toY.round()}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        final isToday = i == todayIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isToday)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                _dayLabels[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isToday ? FontWeight.w800 : FontWeight.w500,
                                  color: isToday
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(7, (i) {
                  final isToday = i == todayIndex;
                  final count = (data[i] ?? 0).toDouble();

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: count,
                        gradient: isToday
                            ? const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color(0xFF2563EB), // primary
                                  Color(0xFF60A5FA), // lighter blue
                                ],
                              )
                            : null,
                        color: isToday
                            ? null
                            : AppColors.textTertiary.withOpacity(0.14),
                        width: 28,
                        borderRadius: BorderRadius.circular(10),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppColors.textTertiary.withOpacity(0.04),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
