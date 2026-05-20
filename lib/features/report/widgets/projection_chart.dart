import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/lung_score_calculator.dart';

class ProjectionChart extends StatelessWidget {
  final int currentAge;
  final String sex;
  final int heightCm;
  final int smokingYears;
  final double cigarettesPerDay;
  final double modifierFactor;

  const ProjectionChart({
    super.key,
    required this.currentAge,
    required this.sex,
    required this.heightCm,
    required this.smokingYears,
    required this.cigarettesPerDay,
    required this.modifierFactor,
  });

  @override
  Widget build(BuildContext context) {
    final data = LungScoreCalculator.computeProjection(
      age: currentAge,
      sex: sex,
      heightCm: heightCm,
      smokingYears: smokingYears,
      cigarettesPerDay: cigarettesPerDay,
      modifierFactor: modifierFactor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Proiezione Fletcher-Peto', style: AppTextStyles.subtitle),
        const SizedBox(height: 6),
        Text(
          'Capacita polmonare stimata nel tempo',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 105,
              minX: currentAge.toDouble(),
              maxX: (currentAge + 40).toDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.textTertiary.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${value.toInt()}',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}%',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Non-smoker (green)
                LineChartBarData(
                  spots: data.nonSmoker
                      .map((p) => FlSpot(p.dx, p.dy))
                      .toList(),
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                // If continue smoking (red/warning)
                LineChartBarData(
                  spots: data.ifContinue
                      .map((p) => FlSpot(p.dx, p.dy))
                      .toList(),
                  isCurved: true,
                  color: AppColors.warning,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      if (index == 0) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.warning,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      }
                      return FlDotCirclePainter(
                        radius: 0,
                        color: Colors.transparent,
                        strokeWidth: 0,
                        strokeColor: Colors.transparent,
                      );
                    },
                  ),
                ),
                // If quit now (dashed blue)
                LineChartBarData(
                  spots: data.ifQuitNow
                      .map((p) => FlSpot(p.dx, p.dy))
                      .toList(),
                  isCurved: true,
                  color: AppColors.accent,
                  barWidth: 2,
                  dashArray: [6, 4],
                  dotData: const FlDotData(show: false),
                ),
              ],
              lineTouchData: const LineTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // "Tu sei qui" marker label
        Row(
          children: [
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.mapPin,
                      size: 12, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    'Tu sei qui ($currentAge anni)',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: AppColors.success, label: 'Non fumatore'),
            const SizedBox(width: 16),
            _LegendItem(color: AppColors.warning, label: 'Se continui'),
            const SizedBox(width: 16),
            _LegendItem(
                color: AppColors.accent, label: 'Se smetti ora', dashed: true),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
