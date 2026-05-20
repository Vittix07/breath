import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

final onboardingProductTypeProvider = StateProvider<String?>((ref) => null);

class ProductTypeScreen extends ConsumerWidget {
  const ProductTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProductTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosa fumi?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/onboarding/step1'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildStepIndicator(2),
              const SizedBox(height: 40),
              _TypeCard(
                icon: LucideIcons.cigarette,
                title: 'Sigarette classiche',
                subtitle: 'Tabacco combusto tradizionale',
                isSelected: selected == 'cigarette',
                onTap: () => ref
                    .read(onboardingProductTypeProvider.notifier)
                    .state = 'cigarette',
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
              const SizedBox(height: 14),
              _TypeCard(
                icon: LucideIcons.zap,
                title: 'IQOS / Tabacco riscaldato',
                subtitle: 'Dispositivi heat-not-burn',
                isSelected: selected == 'iqos',
                onTap: () => ref
                    .read(onboardingProductTypeProvider.notifier)
                    .state = 'iqos',
              )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 400.ms)
                  .slideY(begin: 0.05),
              const SizedBox(height: 14),
              _TypeCard(
                icon: LucideIcons.rotateCcw,
                title: 'Sigarette rollate',
                subtitle: 'Tabacco trinciato arrotolato a mano',
                isSelected: selected == 'rolled',
                onTap: () => ref
                    .read(onboardingProductTypeProvider.notifier)
                    .state = 'rolled',
              )
                  .animate()
                  .fadeIn(delay: 160.ms, duration: 400.ms)
                  .slideY(begin: 0.05),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selected != null
                      ? () => context.go('/onboarding/step3')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textTertiary,
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

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: AppDimensions.cardPadding,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.06)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
