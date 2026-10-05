import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Authentication service wrapping Supabase Auth
class AuthService {
  AuthService._();

  static GoTrueClient get _auth => SupabaseService.auth;

  /// Sign up with email, password, and role
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String language = 'en',
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role,
        'language': language,
      },
    );
    return response;
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  static Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get current session
  static Session? get currentSession => _auth.currentSession;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  /// Get user role from metadata
  static String? get userRole {
    return _auth.currentUser?.userMetadata?['role'] as String?;
  }

  /// Get user name from metadata
  static String? get userName {
    return _auth.currentUser?.userMetadata?['name'] as String?;
  }

  /// Get user language preference from metadata
  static String get userLanguage {
    return (_auth.currentUser?.userMetadata?['language'] as String?) ?? 'en';
  }

  /// Listen to auth state changes
  static Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// Create user profile in profiles table after signup
  static Future<void> createProfile({
    required String userId,
    required String name,
    required String email,
    required String role,
    String language = 'en',
    String? state,
    String? district,
    String? city,
  }) async {
    await SupabaseService.profiles.upsert({
      'id': userId,
      'name': name,
      'email': email,
      'role': role,
      'language': language,
      'state': state ?? 'Tamil Nadu',
      'district': district,
      'city': city,
    });
  }

  /// Create learner profile
  static Future<void> createLearnerProfile({
    required String userId,
    String? educationLevel,
    String? academicScore,
    List<String>? interests,
    List<String>? skills,
    List<String>? preferredIndustries,
    String? salaryExpectation,
    bool? willingToRelocate,
  }) async {
    await SupabaseService.learnerProfiles.upsert({
      'user_id': userId,
      'education_level': educationLevel,
      'academic_score': academicScore,
      'interests': interests,
      'skills': skills,
      'preferred_industries': preferredIndustries,
      'salary_expectation': salaryExpectation,
      'willing_to_relocate': willingToRelocate ?? false,
    });
  }

  /// Create parent profile
  static Future<void> createParentProfile({
    required String userId,
    String? learnerId,
    List<String>? concerns,
    Map<String, dynamic>? expectations,
  }) async {
    await SupabaseService.parentProfiles.upsert({
      'user_id': userId,
      'learner_id': learnerId,
      'concerns': concerns,
      'expectations': expectations,
    });
  }
}
