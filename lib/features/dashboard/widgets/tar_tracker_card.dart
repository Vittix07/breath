import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class TarTrackerCard extends StatelessWidget {
  final double tarGrams;
  final bool isHeatedProduct;

  const TarTrackerCard({
    super.key,
    required this.tarGrams,
    this.isHeatedProduct = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = isHeatedProduct && tarGrams == 0
        ? '0 g'
        : '${tarGrams.toStringAsFixed(2)} g';
    final subtitle =
        isHeatedProduct && tarGrams == 0 ? 'nessuna combustione' : 'questo mese';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.55, 1.0],
            colors: [
              AppColors.fuchsia,
              AppColors.violet.withOpacity(0.90),
              AppColors.violet.withOpacity(0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.fuchsia.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.fuchsia.withOpacity(0.10),
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
                      child: const Icon(LucideIcons.droplets,
                          size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CATRAME',
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
                Text(
                  display,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.70),
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
