import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/animated_number.dart';

class MoneyTrackerCard extends StatelessWidget {
  final double amountSpent;
  final int cigarettesInCurrentPack;
  final int packSize;

  const MoneyTrackerCard({
    super.key,
    required this.amountSpent,
    this.cigarettesInCurrentPack = 0,
    this.packSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final progress = packSize > 0 ? cigarettesInCurrentPack / packSize : 0.0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.55, 1.0],
            colors: [
              AppColors.amber,
              AppColors.orange.withOpacity(0.90),
              AppColors.orange.withOpacity(0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.amber.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.amber.withOpacity(0.10),
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
                      child: const Icon(LucideIcons.coins,
                          size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SPESO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.75),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AnimatedDouble(
                  value: amountSpent,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                  decimals: 0,
                  suffix: '€',
                ),
                const SizedBox(height: 4),
                Text(
                  'questo mese',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.70),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pacchetto: $cigarettesInCurrentPack/$packSize',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
