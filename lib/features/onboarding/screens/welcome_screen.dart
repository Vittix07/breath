import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.wind,
                  size: 48,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutCubic),
              const SizedBox(height: 32),
              Text(
                'Breath',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 36),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                'Capisci cosa fumi.\nSenza giudizio.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/onboarding/step1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Iniziamo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(
                    begin: 0.2,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
