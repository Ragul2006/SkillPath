import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper around Supabase client for convenient access
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static String? get currentUserId => auth.currentUser?.id;

  static bool get isAuthenticated => auth.currentUser != null;

  /// Initialize Supabase — call once in main()
  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    await Supabase.initialize(
      url: url,
      // ignore: deprecated_member_use
      anonKey: anonKey,
    );
  }

  // ── Table accessors ──
  static SupabaseQueryBuilder table(String name) => client.from(name);

  static SupabaseQueryBuilder get profiles => table('profiles');
  static SupabaseQueryBuilder get learnerProfiles => table('learner_profiles');
  static SupabaseQueryBuilder get parentProfiles => table('parent_profiles');
  static SupabaseQueryBuilder get familyLinks => table('family_links');
  static SupabaseQueryBuilder get trades => table('trades');
  static SupabaseQueryBuilder get careerRoles => table('career_roles');
  static SupabaseQueryBuilder get careerPaths => table('career_paths');
  static SupabaseQueryBuilder get trainingProviders => table('training_providers');
  static SupabaseQueryBuilder get outcomes => table('outcomes');
  static SupabaseQueryBuilder get conversations => table('conversations');
  static SupabaseQueryBuilder get messages => table('messages');
  static SupabaseQueryBuilder get concerns => table('concerns');
  static SupabaseQueryBuilder get escalations => table('escalations');
  static SupabaseQueryBuilder get sentimentEvents => table('sentiment_events');
  static SupabaseQueryBuilder get recommendations => table('recommendations');
}
