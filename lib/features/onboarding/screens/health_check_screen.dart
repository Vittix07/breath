import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_profile.dart';
import '../../../providers/user_provider.dart';
import 'profile_step_screen.dart';
import 'product_type_screen.dart';

final _exerciseLevelProvider = StateProvider<int>((ref) => 1);
final _coughProvider = StateProvider<bool>((ref) => false);
final _breathProvider = StateProvider<bool>((ref) => false);
final _stressProvider = StateProvider<bool>((ref) => true);

class HealthCheckScreen extends ConsumerWidget {
  const HealthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseLevel = ref.watch(_exerciseLevelProvider);
    final cough = ref.watch(_coughProvider);
    final breath = ref.watch(_breathProvider);
    final stress = ref.watch(_stressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick health check'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/onboarding/step2'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildStepIndicator(3),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise level (0-3)
                      Text('Attivita fisica', style: AppTextStyles.subtitle)
                          .animate()
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _ExerciseChip(
                            label: 'Nulla',
                            isSelected: exerciseLevel == 0,
                            onTap: () => ref
                                .read(_exerciseLevelProvider.notifier)
                                .state = 0,
                          ),
                          const SizedBox(width: 8),
                          _ExerciseChip(
                            label: 'Leggera',
                            isSelected: exerciseLevel == 1,
                            onTap: () => ref
                                .read(_exerciseLevelProvider.notifier)
                                .state = 1,
                          ),
                          const SizedBox(width: 8),
                          _ExerciseChip(
                            label: 'Moderata',
                            isSelected: exerciseLevel == 2,
                            onTap: () => ref
                                .read(_exerciseLevelProvider.notifier)
                                .state = 2,
                          ),
                          const SizedBox(width: 8),
                          _ExerciseChip(
                            label: 'Intensa',
                            isSelected: exerciseLevel == 3,
                            onTap: () => ref
                                .read(_exerciseLevelProvider.notifier)
                                .state = 3,
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 20),
                      _QuestionToggle(
                        icon: LucideIcons.wind,
                        question: 'Hai tosse frequente al mattino?',
                        value: cough,
                        onChanged: (v) =>
                            ref.read(_coughProvider.notifier).state = v,
                      )
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 400.ms)
                          .slideY(begin: 0.05),
                      const SizedBox(height: 14),
                      _QuestionToggle(
                        icon: LucideIcons.heartPulse,
                        question: 'Ti capita di avere il fiato corto?',
                        value: breath,
                        onChanged: (v) =>
                            ref.read(_breathProvider.notifier).state = v,
                      )
                          .animate()
                          .fadeIn(delay: 160.ms, duration: 400.ms)
                          .slideY(begin: 0.05),
                      const SizedBox(height: 14),
                      _QuestionToggle(
                        icon: LucideIcons.zap,
                        question: 'Fumi di piu in situazioni di stress?',
                        value: stress,
                        onChanged: (v) =>
                            ref.read(_stressProvider.notifier).state = v,
                      )
                          .animate()
                          .fadeIn(delay: 240.ms, duration: 400.ms)
                          .slideY(begin: 0.05),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final profile = UserProfile(
                      age: ref.read(onboardingAgeProvider),
                      smokingYears: ref.read(onboardingYearsProvider),
                      cigarettesPerDay: ref.read(onboardingCigsProvider),
                      productType:
                          ref.read(onboardingProductTypeProvider) ?? 'cigarette',
                      doesExercise: exerciseLevel >= 2,
                      morningCough: cough,
                      shortnessOfBreath: breath,
                      stressSmoker: stress,
                      biologicalSex: ref.read(onboardingSexProvider),
                      heightCm: ref.read(onboardingHeightProvider),
                      ageFirstCigarette: ref.read(onboardingAgeFirstCigProvider),
                      exerciseLevel: exerciseLevel,
                      baselineCough: cough ? 4 : 1,
                      baselineBreathlessness: breath ? 4 : 1,
                    );
                    await ref.read(userProfileProvider.notifier).save(profile);
                    if (context.mounted) context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Inizia il tracking',
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

class _ExerciseChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseChip({
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textTertiary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionToggle extends StatelessWidget {
  final IconData icon;
  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _QuestionToggle({
    required this.icon,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(question, style: AppTextStyles.body),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _ToggleChip(
                label: 'Si',
                isSelected: value,
                onTap: () => onChanged(true),
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                label: 'No',
                isSelected: !value,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
