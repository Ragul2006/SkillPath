import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/services/auth_service.dart';
import '../core/services/supabase_service.dart';

/// Auth state — tracks current auth status + user metadata
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? role;
  final String? name;
  final String? error;
  final bool onboardingComplete;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.role,
    this.name,
    this.error,
    this.onboardingComplete = true,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? role,
    String? name,
    String? error,
    bool? onboardingComplete,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      role: role ?? this.role,
      name: name ?? this.name,
      error: error,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    // Check current session from Supabase
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        String? role = user.userMetadata?['role'] as String?;
        String? name = user.userMetadata?['name'] as String?;

        if (role == null) {
          try {
            final profile = await SupabaseService.profiles
                .select('role, name')
                .eq('id', user.id)
                .maybeSingle();
            if (profile != null) {
              role = profile['role'] as String?;
              name = name ?? profile['name'] as String?;
            }
          } catch (_) {}
        }

        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          role: role ?? AppConstants.roleLearner,
          name: name ?? user.email?.split('@').first ?? 'User',
          onboardingComplete: true,
        );
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (_) {
      state = const AuthState(isLoading: false);
    }

    // Listen to Supabase auth changes
    SupabaseService.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        final user = session.user;
        String? role = user.userMetadata?['role'] as String?;
        String? name = user.userMetadata?['name'] as String?;

        if (role == null) {
          try {
            final profile = await SupabaseService.profiles
                .select('role, name')
                .eq('id', user.id)
                .maybeSingle();
            if (profile != null) {
              role = profile['role'] as String?;
              name = name ?? profile['name'] as String?;
            }
          } catch (_) {}
        }

        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          role: role ?? AppConstants.roleLearner,
          name: name ?? user.email?.split('@').first ?? 'User',
          onboardingComplete: true,
        );
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AuthState(isLoading: false);
      }
    });
  }

  /// Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String language = 'en',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await AuthService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        language: language,
      );

      if (response.user != null) {
        // Attempt to create profile in database
        try {
          await AuthService.createProfile(
            userId: response.user!.id,
            name: name,
            email: email,
            role: role,
            language: language,
          );
        } catch (_) {}

        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
          role: role,
          name: name,
          onboardingComplete: true,
        );
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
      return false;
    }
  }

  /// Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        String? role = response.user!.userMetadata?['role'] as String?;
        String? name = response.user!.userMetadata?['name'] as String?;

        if (role == null) {
          try {
            final profile = await SupabaseService.profiles
                .select('role, name')
                .eq('id', response.user!.id)
                .maybeSingle();
            if (profile != null) {
              role = profile['role'] as String?;
              name = name ?? profile['name'] as String?;
            }
          } catch (_) {}
        }

        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          user: response.user,
          role: role ?? AppConstants.roleLearner,
          name: name ?? response.user!.email?.split('@').first ?? 'User',
          onboardingComplete: true,
        );
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
      return false;
    }
  }

  /// Instant Demo Sign In for evaluation & hackathon presentation
  void demoSignIn(String role) {
    String name = 'Demo User';
    if (role == AppConstants.roleLearner) {
      name = 'Kavitha (Learner)';
    } else if (role == AppConstants.roleParent) {
      name = 'Ragul (Parent)';
    } else if (role == AppConstants.roleCounsellor) {
      name = 'Dr. Anitha (Counsellor)';
    } else if (role == AppConstants.roleAdmin) {
      name = 'Admin Officer';
    }

    state = AuthState(
      isLoading: false,
      isAuthenticated: true,
      role: role,
      name: name,
      onboardingComplete: true,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await AuthService.signOut();
    } catch (_) {}
    state = const AuthState(isLoading: false, isAuthenticated: false);
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
  }

  /// Mark onboarding as complete
  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _parseError(dynamic e) {
    if (e is AuthException) {
      return e.message;
    }
    return e.toString();
  }
}

/// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
