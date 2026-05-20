import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

final onboardingAgeProvider = StateProvider<int>((ref) => 22);
final onboardingYearsProvider = StateProvider<int>((ref) => 3);
final onboardingCigsProvider = StateProvider<double>((ref) => 10);
final onboardingSexProvider = StateProvider<String>((ref) => 'male');
final onboardingHeightProvider = StateProvider<int>((ref) => 175);
final onboardingAgeFirstCigProvider = StateProvider<int>((ref) => 16);

class ProfileStepScreen extends ConsumerWidget {
  const ProfileStepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final age = ref.watch(onboardingAgeProvider);
    final years = ref.watch(onboardingYearsProvider);
    final cigs = ref.watch(onboardingCigsProvider);
    final sex = ref.watch(onboardingSexProvider);
    final height = ref.watch(onboardingHeightProvider);
    final ageFirstCig = ref.watch(onboardingAgeFirstCigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il tuo profilo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildStepIndicator(1),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sex selector
                      Text('Sesso biologico', style: AppTextStyles.subtitle)
                          .animate()
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _SexChip(
                            label: 'Maschio',
                            isSelected: sex == 'male',
                            onTap: () => ref
                                .read(onboardingSexProvider.notifier)
                                .state = 'male',
                          ),
                          const SizedBox(width: 12),
                          _SexChip(
                            label: 'Femmina',
                            isSelected: sex == 'female',
                            onTap: () => ref
                                .read(onboardingSexProvider.notifier)
                                .state = 'female',
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 24),
                      _SliderField(
                        label: 'Quanti anni hai?',
                        value: age.toDouble(),
                        min: 14,
                        max: 50,
                        displayValue: '$age anni',
                        onChanged: (v) =>
                            ref.read(onboardingAgeProvider.notifier).state =
                                v.round(),
                      ).animate().fadeIn(delay: 50.ms, duration: 400.ms).slideY(begin: 0.05),
                      const SizedBox(height: 24),
                      _SliderField(
                        label: 'Altezza',
                        value: height.toDouble(),
                        min: 140,
                        max: 210,
                        displayValue: '$height cm',
                        onChanged: (v) =>
                            ref.read(onboardingHeightProvider.notifier).state =
                                v.round(),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05),
                      const SizedBox(height: 24),
                      _SliderField(
                        label: 'Da quanti anni fumi?',
                        value: years.toDouble(),
                        min: 1,
                        max: 30,
                        displayValue: '$years anni',
                        onChanged: (v) =>
                            ref.read(onboardingYearsProvider.notifier).state =
                                v.round(),
                      )
                          .animate()
                          .fadeIn(delay: 150.ms, duration: 400.ms)
                          .slideY(begin: 0.05),
                      const SizedBox(height: 24),
                      _SliderField(
                        label: 'A che eta hai iniziato?',
                        value: ageFirstCig.toDouble(),
                        min: 10,
                        max: 40,
                        displayValue: '$ageFirstCig anni',
                        onChanged: (v) =>
                            ref.read(onboardingAgeFirstCigProvider.notifier).state =
                                v.round(),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.05),
                      const SizedBox(height: 24),
                      _SliderField(
                        label: 'Media sigarette al giorno?',
                        value: cigs,
                        min: 1,
                        max: 40,
                        displayValue: '${cigs.round()}/giorno',
                        onChanged: (v) =>
                            ref.read(onboardingCigsProvider.notifier).state =
                                v.roundToDouble(),
                      )
                          .animate()
                          .fadeIn(delay: 250.ms, duration: 400.ms)
                          .slideY(begin: 0.05),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/onboarding/step2'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continua',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i < step;
        final isCurrent = i == step - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.textTertiary,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

class _SexChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SexChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.subtitle),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                displayValue,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.12),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
