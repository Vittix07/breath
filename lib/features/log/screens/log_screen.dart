import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/log_provider.dart';

Future<void> quickLogCigarette(BuildContext context, WidgetRef ref) async {
  HapticFeedback.mediumImpact();
  await ref.read(cigaretteLogsProvider.notifier).addLog();
  if (!context.mounted) return;

  final todayCount = ref.read(todayLogsProvider).length;

  final overlay = OverlayEntry(
    builder: (ctx) => _QuickLogToast(count: todayCount),
  );
  Overlay.of(context).insert(overlay);
  await Future.delayed(const Duration(milliseconds: 1600));
  overlay.remove();
}

void showLogSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LogSheetContent(),
  );
}

class _QuickLogToast extends StatelessWidget {
  final int count;
  const _QuickLogToast({required this.count});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.check,
                      size: 16, color: AppColors.success),
                ),
                const SizedBox(width: 10),
                Text(
                  'Registrata  ·  Oggi: $count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.3, curve: Curves.easeOutCubic)
              .then(delay: 1000.ms)
              .fadeOut(duration: 300.ms)
              .slideY(end: 0.2),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Log Sheet — griglia 2×3 con animazione in-place
// ---------------------------------------------------------------------------

class _LogSheetContent extends ConsumerStatefulWidget {
  const _LogSheetContent();

  @override
  ConsumerState<_LogSheetContent> createState() => _LogSheetContentState();
}

class _LogSheetContentState extends ConsumerState<_LogSheetContent>
    with TickerProviderStateMixin {
  int? _selectedIndex;

  late final AnimationController _phaseController;
  late final AnimationController _pulseController;

  static const _contexts = [
    ('stress', LucideIcons.zap, 'Stress', AppColors.rose),
    ('social', LucideIcons.users, 'Sociale', AppColors.violet),
    ('boredom', LucideIcons.clock, 'Noia', AppColors.amber),
    ('after_coffee', LucideIcons.coffee, 'Caffe', AppColors.orange),
    ('after_meal', LucideIcons.utensilsCrossed, 'Pasto', AppColors.emerald),
    ('other', LucideIcons.moreHorizontal, 'Altro', AppColors.sky),
  ];

  // Direzioni di uscita per layout 2×3
  static const _exitOffsets = [
    Offset(-1.2, -0.6),  // r0c0 → left-up
    Offset(1.2, -0.6),   // r0c1 → right-up
    Offset(-1.3, 0.0),   // r1c0 → left
    Offset(1.3, 0.0),    // r1c1 → right
    Offset(-1.2, 0.6),   // r2c0 → left-down
    Offset(1.2, 0.6),    // r2c1 → right-down
  ];

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _logWith(int index) async {
    if (_selectedIndex != null) return;

    final ctx = _contexts[index];
    HapticFeedback.heavyImpact();

    setState(() => _selectedIndex = index);
    _phaseController.forward();

    await ref.read(cigaretteLogsProvider.notifier).addLog(context: ctx.$1);

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _pulseController.repeat();

    await Future.delayed(const Duration(milliseconds: 250));
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final todayCount = ref.watch(todayLogsProvider).length;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: Listenable.merge([_phaseController, _pulseController]),
      builder: (context, _) {
        final p = _phaseController.value;
        final hasSelection = _selectedIndex != null;

        final headerOpacity =
            hasSelection ? (1.0 - p * 2.5).clamp(0.0, 1.0) : 1.0;
        final successOpacity =
            hasSelection ? ((p - 0.35) / 0.3).clamp(0.0, 1.0) : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),

              // Header
              SizedBox(
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: headerOpacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Come mai?',
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          Text('Oggi: $todayCount sigarette',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    if (hasSelection)
                      Opacity(
                        opacity: successOpacity,
                        child: Transform.translate(
                          offset: Offset(0, 6 * (1 - successOpacity)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Registrata!',
                                  style: AppTextStyles.titleMedium),
                              const SizedBox(height: 6),
                              Text('Oggi: $todayCount sigarette',
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Griglia 2×3
              _buildRow(0, 1, p),
              const SizedBox(height: 10),
              _buildRow(2, 3, p),
              const SizedBox(height: 10),
              _buildRow(4, 5, p),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(int left, int right, double p) {
    return Row(
      children: [
        _buildCard(left, p),
        const SizedBox(width: 10),
        _buildCard(right, p),
      ],
    );
  }

  Widget _buildCard(int index, double p) {
    final c = _contexts[index];
    final isSelected = _selectedIndex == index;
    final hasSelection = _selectedIndex != null;
    final isOther = hasSelection && !isSelected;

    // Exit
    final staggerDelay = index * 0.03;
    final exitProgress =
        isOther ? ((p - staggerDelay) / 0.35).clamp(0.0, 1.0) : 0.0;
    final exitCurved = Curves.easeInBack.transform(exitProgress);

    final exitOff = _exitOffsets[index];
    final translateX = isOther ? exitCurved * exitOff.dx * 100 : 0.0;
    final translateY = isOther ? exitCurved * exitOff.dy * 60 : 0.0;
    final otherOpacity = isOther ? (1.0 - exitProgress).clamp(0.0, 1.0) : 1.0;
    final otherScale =
        isOther ? (1.0 - exitProgress * 0.2).clamp(0.0, 1.0) : 1.0;
    final otherRotation = isOther ? exitCurved * exitOff.dx * 0.1 : 0.0;

    // Selected
    final fillProgress = isSelected ? (p / 0.3).clamp(0.0, 1.0) : 0.0;
    final fillCurved = Curves.easeOutCubic.transform(fillProgress);
    final celebrateProgress =
        isSelected ? ((p - 0.3) / 0.3).clamp(0.0, 1.0) : 0.0;
    final celebrateCurved = Curves.elasticOut.transform(celebrateProgress);
    final selectedScale = isSelected ? 1.0 + celebrateCurved * 0.06 : otherScale;
    final checkProgress =
        isSelected ? ((p - 0.4) / 0.25).clamp(0.0, 1.0) : 0.0;
    final checkCurved = Curves.elasticOut.transform(checkProgress);

    final pulseP = _pulseController.value;
    final showPulse = isSelected && celebrateProgress > 0.5;

    return Expanded(
      child: GestureDetector(
        onTap: hasSelection ? null : () => _logWith(index),
        child: Transform.translate(
          offset: Offset(translateX, translateY),
          child: Transform.rotate(
            angle: otherRotation,
            child: Transform.scale(
              scale: selectedScale,
              child: Opacity(
                opacity: otherOpacity,
                child: Stack(
                  children: [
                    // Ring pulse
                    if (showPulse)
                      Positioned.fill(
                        child: Transform.scale(
                          scale: 1.0 + pulseP * 0.15,
                          child: Opacity(
                            opacity: (1.0 - pulseP) * 0.3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: c.$4, width: 2.5),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color.lerp(
                                c.$4.withOpacity(0.08), c.$4, fillCurved)
                            : c.$4.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? c.$4.withOpacity(0.3 + fillCurved * 0.7)
                              : c.$4.withOpacity(0.15),
                          width: isSelected && fillCurved > 0.5 ? 2 : 1,
                        ),
                        boxShadow: isSelected && celebrateProgress > 0
                            ? [
                                BoxShadow(
                                  color: c.$4
                                      .withOpacity(0.3 * celebrateCurved),
                                  blurRadius: 18 * celebrateCurved,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected && fillCurved > 0.4
                                  ? Colors.white
                                      .withOpacity(0.15 + 0.15 * fillCurved)
                                  : c.$4.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: checkProgress > 0 && isSelected
                                ? Transform.scale(
                                    scale: checkCurved,
                                    child: const Icon(LucideIcons.check,
                                        size: 24, color: Colors.white),
                                  )
                                : Icon(c.$2,
                                    size: 22,
                                    color: isSelected && fillCurved > 0.5
                                        ? Colors.white
                                        : c.$4),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              c.$3,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isSelected && fillCurved > 0.5
                                    ? Colors.white
                                    : c.$4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
