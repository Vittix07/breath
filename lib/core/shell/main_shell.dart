import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../../features/log/screens/log_screen.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/report') return 1;
    if (location == '/profile') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _currentIndex(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: child,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? 0 : 10),
            child: Container(
              height: 68,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.navBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 28,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.home,
                      label: 'Home',
                      isActive: index == 0,
                      activeColor: AppColors.primary,
                      onTap: () => context.go('/'),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.barChart3,
                      label: 'Report',
                      isActive: index == 1,
                      activeColor: AppColors.teal,
                      onTap: () => context.go('/report'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _AnimatedFab(
                      onTap: () => quickLogCigarette(context, ref),
                      onLongPress: () => showLogSheet(context),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.user,
                      label: 'Profilo',
                      isActive: index == 3,
                      activeColor: AppColors.violet,
                      onTap: () => context.go('/profile'),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.settings,
                      label: 'Altro',
                      isActive: false,
                      activeColor: AppColors.textSecondary,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedFab extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _AnimatedFab({required this.onTap, required this.onLongPress});

  @override
  State<_AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<_AnimatedFab>
    with TickerProviderStateMixin {
  static const _blueColor = Color(0xFF3B82F6);
  static const _greenColor = Color(0xFF22C55E);

  late final AnimationController _scaleController;
  late final AnimationController _colorController;
  late final Animation<double> _scaleAnim;
  late final Animation<Color?> _colorAnim;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Blue → Green fast, hold green, then Green → Blue slow
    _colorAnim = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: _blueColor, end: _greenColor),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Color?>(_greenColor),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: _greenColor, end: _blueColor),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(parent: _colorController, curve: Curves.easeInOut));

    _checkScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_colorController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    HapticFeedback.heavyImpact();

    _scaleController.forward().then((_) => _scaleController.reverse());
    _colorController.forward(from: 0);

    widget.onTap();

    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.lightImpact();
  }

  void _handleLongPress() {
    HapticFeedback.heavyImpact();
    widget.onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onTapDown: (_) => _scaleController.forward(),
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnim, _colorAnim, _checkScale]),
        builder: (context, child) {
          final color = _colorAnim.value ?? _blueColor;
          final isAnimating = _colorController.isAnimating;

          return SizedBox(
            width: 64,
            height: 64,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: isAnimating && _checkScale.value > 0.01
                      ? Transform.scale(
                          scale: _checkScale.value,
                          child: const Icon(
                            LucideIcons.check,
                            color: Colors.white,
                            size: 26,
                          ),
                        )
                      : const Icon(
                          LucideIcons.plus,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? activeColor : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? activeColor : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
