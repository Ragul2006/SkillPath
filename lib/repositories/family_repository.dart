import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';
import '../models/concern.dart';

/// Repository for handling parent concerns and family decision data
class FamilyRepository {
  /// Fetch all concerns for a user or family
  static Future<List<Concern>> getConcerns(String userId) async {
    try {
      final data = await SupabaseService.concerns
          .select('*')
          .eq('user_id', userId)
          .order('id');

      final list = (data as List<dynamic>)
          .map((item) => Concern.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('Error fetching concerns from Supabase: $e');
    }

    // Default demo concerns for presentation
    return [
      Concern(
        id: '1',
        userId: userId,
        category: 'Job Security',
        description: 'Will this trade offer steady employment during industry downturns?',
        severity: 'high',
        status: 'addressed',
      ),
      Concern(
        id: '2',
        userId: userId,
        category: 'Starting Salary',
        description: 'Is ₹16,000–₹20,000 sufficient for family living expenses in the first year?',
        severity: 'medium',
        status: 'open',
      ),
      Concern(
        id: '3',
        userId: userId,
        category: 'Career Growth',
        description: 'Can my child progress to higher supervisory or engineering diplomas later?',
        severity: 'medium',
        status: 'open',
      ),
    ];
  }

  /// Add a new concern
  static Future<bool> addConcern(Concern concern) async {
    try {
      await SupabaseService.concerns.insert(concern.toJson());
      return true;
    } catch (e) {
      debugPrint('Error inserting concern: $e');
      return false;
    }
  }

  /// Mark a concern as addressed or resolved
  static Future<bool> updateConcernStatus(String concernId, String status) async {
    try {
      await SupabaseService.concerns
          .update({'status': status})
          .eq('id', concernId);
      return true;
    } catch (e) {
      debugPrint('Error updating concern: $e');
      return false;
    }
  }
}
