import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/profile_step_screen.dart';
import '../../features/onboarding/screens/product_type_screen.dart';
import '../../features/onboarding/screens/health_check_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/report/screens/report_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../providers/user_provider.dart';
import '../shell/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final goingToOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!onboardingDone && !goingToOnboarding) return '/onboarding';
      if (onboardingDone && goingToOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/step1',
        builder: (_, __) => const ProfileStepScreen(),
      ),
      GoRoute(
        path: '/onboarding/step2',
        builder: (_, __) => const ProductTypeScreen(),
      ),
      GoRoute(
        path: '/onboarding/step3',
        builder: (_, __) => const HealthCheckScreen(),
      ),
      ShellRoute(
        builder: (_, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/report', builder: (_, __) => const ReportScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
