import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/cost_calculator.dart';
import '../../../core/utils/nicotine_calculator.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/log_provider.dart';
import '../../../shared/widgets/breath_card.dart';
import '../../../shared/widgets/animated_number.dart' show AnimatedNumber, AnimatedDouble;
import '../../report/widgets/disclaimer_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    if (profile == null) return const SizedBox.shrink();

    final allLogs = ref.watch(cigaretteLogsProvider);

    final totalSpent = CostCalculator.moneySpent(
      cigaretteCount: allLogs.length,
      packSize: 20,
      packPrice: profile.effectivePackPrice,
    );

    final totalTarGrams = NicotineCalculator.tarInhaledGrams(
      allLogs.length,
      profile.effectiveTarMg,
    );

    final productLabels = {
      'cigarette': 'Sigarette classiche',
      'iqos': 'IQOS / Tabacco riscaldato',
      'rolled': 'Sigarette rollate',
      'mixed': 'Misto',
    };

    final sexLabels = {
      'male': 'Maschio',
      'female': 'Femmina',
    };

    final exerciseLabels = {
      0: 'Sedentario',
      1: 'Leggera',
      2: 'Moderata',
      3: 'Intensa',
    };

    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profilo', style: AppTextStyles.titleLarge)
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          BreathCard(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.user,
                      size: 28, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                _ProfileRow(
                    label: 'Eta', value: '${profile.age} anni'),
                _ProfileRow(
                    label: 'Sesso',
                    value: sexLabels[profile.biologicalSex] ?? profile.biologicalSex),
                _ProfileRow(
                    label: 'Altezza',
                    value: '${profile.heightCm} cm'),
                _ProfileRow(
                    label: 'Anni di fumo',
                    value: '${profile.smokingYears}'),
                _ProfileRow(
                    label: 'Sigarette/giorno',
                    value: '${profile.cigarettesPerDay.round()}/giorno'),
                _ProfileRow(
                    label: 'Prodotto',
                    value: productLabels[profile.productType] ??
                        profile.productType),
                _ProfileRow(
                    label: 'Prezzo pacchetto',
                    value: '${profile.effectivePackPrice.toStringAsFixed(2)}€'),
                _ProfileRow(
                    label: 'Prima sigaretta a',
                    value: '${profile.ageFirstCigarette} anni'),
                _ProfileRow(
                    label: 'Attivita fisica',
                    value: exerciseLabels[profile.exerciseLevel] ?? '${profile.exerciseLevel}'),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),
          const SizedBox(height: 14),
          Text('Statistiche lifetime', style: AppTextStyles.subtitle)
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BreathCard(
                  child: Column(
                    children: [
                      Icon(LucideIcons.cigarette,
                          size: 22, color: AppColors.primary),
                      const SizedBox(height: 10),
                      AnimatedNumber(
                        value: allLogs.length,
                        style: AppTextStyles.statNumberSmall,
                      ),
                      const SizedBox(height: 4),
                      Text('Totale loggate',
                          style: AppTextStyles.label,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: BreathCard(
                  child: Column(
                    children: [
                      Icon(LucideIcons.coins,
                          size: 22, color: AppColors.warning),
                      const SizedBox(height: 10),
                      AnimatedDouble(
                        value: totalSpent,
                        style: AppTextStyles.statNumberSmall,
                        decimals: 0,
                        suffix: '€',
                      ),
                      const SizedBox(height: 4),
                      Text('Totale speso',
                          style: AppTextStyles.label,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.05),
          const SizedBox(height: 14),
          BreathCard(
            child: Row(
              children: [
                Icon(LucideIcons.droplets, size: 22, color: AppColors.indigo),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Catrame inalato totale',
                        style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      '${totalTarGrams.toStringAsFixed(2)} g',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideY(begin: 0.05),
          const SizedBox(height: 24),
          const DisclaimerCard()
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

