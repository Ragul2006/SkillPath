import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../constants/app_constants.dart';

// ── Screen imports ──
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/onboarding/learner_profile_setup_screen.dart';
import '../../screens/onboarding/parent_profile_setup_screen.dart';
import '../../screens/home/learner_home_screen.dart';
import '../../screens/home/parent_home_screen.dart';
import '../../screens/home/counsellor_dashboard_screen.dart';
import '../../screens/home/admin_dashboard_screen.dart';
import '../../screens/careers/career_explorer_screen.dart';
import '../../screens/careers/career_detail_screen.dart';
import '../../screens/careers/career_path_screen.dart';
import '../../screens/comparison/comparison_screen.dart';
import '../../screens/counsellor/ai_counsellor_screen.dart';
import '../../screens/family/family_dashboard_screen.dart';
import '../../screens/escalation/create_escalation_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';

/// RouterNotifier notifies GoRouter when AuthState changes without recreating the router
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, _) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final isLoading = authState.isLoading;
    final isAuth = authState.isAuthenticated;
    final path = state.uri.path;

    // While checking session on launch, stay put
    if (isLoading) return null;

    final publicRoutes = [
      '/',
      '/login',
      '/signup',
      '/forgot-password',
    ];

    // Not authenticated -> redirect unauthenticated routes back to onboarding
    if (!isAuth) {
      if (publicRoutes.contains(path)) return null;
      return '/';
    }

    // Authenticated and on public route (e.g. '/' or '/login') -> redirect to home
    if (publicRoutes.contains(path)) {
      return homeRouteForRole(authState.role);
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// App router provider
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    debugLogDiagnostics: true,
    routes: [
      // ── Onboarding / Auth ──
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding/learner-setup',
        builder: (context, state) => const LearnerProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/parent-setup',
        builder: (context, state) => const ParentProfileSetupScreen(),
      ),

      // ── Learner Home ──
      GoRoute(
        path: '/learner',
        builder: (context, state) => const LearnerHomeScreen(),
      ),

      // ── Parent Home ──
      GoRoute(
        path: '/parent',
        builder: (context, state) => const ParentHomeScreen(),
      ),

      // ── Counsellor Dashboard ──
      GoRoute(
        path: '/counsellor',
        builder: (context, state) => const CounsellorDashboardScreen(),
      ),

      // ── Admin Dashboard ──
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // ── Career Explorer ──
      GoRoute(
        path: '/careers',
        builder: (context, state) => const CareerExplorerScreen(),
      ),
      GoRoute(
        path: '/careers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CareerDetailScreen(tradeId: id);
        },
      ),
      GoRoute(
        path: '/careers/:id/path',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CareerPathScreen(tradeId: id);
        },
      ),

      // ── Comparison ──
      GoRoute(
        path: '/comparison',
        builder: (context, state) => const ComparisonScreen(),
      ),

      // ── AI Counsellor ──
      GoRoute(
        path: '/ai-counsellor',
        builder: (context, state) => const AiCounsellorScreen(),
      ),

      // ── Family Dashboard ──
      GoRoute(
        path: '/family',
        builder: (context, state) => const FamilyDashboardScreen(),
      ),

      // ── Escalation ──
      GoRoute(
        path: '/escalate',
        builder: (context, state) => const CreateEscalationScreen(),
      ),

      // ── Profile ──
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // ── Settings ──
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
});

String homeRouteForRole(String? role) {
  switch (role) {
    case AppConstants.roleLearner:
      return '/learner';
    case AppConstants.roleParent:
      return '/parent';
    case AppConstants.roleCounsellor:
      return '/counsellor';
    case AppConstants.roleAdmin:
      return '/admin';
    default:
      return '/learner';
  }
}
