import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';
import '../models/escalation.dart';

/// Repository for managing counsellor escalations
class EscalationRepository {
  /// Fetch escalations for a user
  static Future<List<ScalableEscalationItem>> getEscalations({String? counsellorId}) async {
    try {
      var builder = SupabaseService.escalations.select('*, profiles:user_id(name, email, district)');
      if (counsellorId != null) {
        builder = builder.eq('assigned_counsellor', counsellorId);
      }

      final data = await builder.order('created_at', ascending: false);
      final list = (data as List<dynamic>)
          .map((item) => ScalableEscalationItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('Error fetching escalations: $e');
    }

    // Default demo escalations for Counsellor / Admin views
    return [
      ScalableEscalationItem(
        id: 'esc-1',
        userName: 'Senthil Kumar (Parent)',
        district: 'Salem',
        reason: 'Parent has hesitation regarding starting salary of CNC Operator vs Polytechnic Diploma.',
        priority: 'High',
        status: 'Pending',
        timeAgo: '2 hours ago',
      ),
      ScalableEscalationItem(
        id: 'esc-2',
        userName: 'Kavitha R (Student)',
        district: 'Coimbatore',
        reason: 'Evaluating Electrician vs Solar Technician apprenticeships near Coimbatore.',
        priority: 'Medium',
        status: 'In Progress',
        timeAgo: 'Yesterday',
      ),
      ScalableEscalationItem(
        id: 'esc-3',
        userName: 'Muthu P (Parent)',
        district: 'Madurai',
        reason: 'Questions regarding safety protocols and certifications for Welder trade.',
        priority: 'Low',
        status: 'Resolved',
        timeAgo: '3 days ago',
      ),
    ];
  }

  /// Submit a new escalation
  static Future<bool> createEscalation(Escalation escalation) async {
    try {
      await SupabaseService.escalations.insert(escalation.toJson());
      return true;
    } catch (e) {
      debugPrint('Error creating escalation: $e');
      return false;
    }
  }
}

/// View-friendly escalation item model
class ScalableEscalationItem {
  final String id;
  final String userName;
  final String district;
  final String reason;
  final String priority;
  final String status;
  final String timeAgo;

  const ScalableEscalationItem({
    required this.id,
    required this.userName,
    required this.district,
    required this.reason,
    required this.priority,
    required this.status,
    required this.timeAgo,
  });

  factory ScalableEscalationItem.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return ScalableEscalationItem(
      id: json['id']?.toString() ?? '',
      userName: profile?['name']?.toString() ?? 'Learner',
      district: profile?['district']?.toString() ?? 'Tamil Nadu',
      reason: json['reason']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'Medium',
      status: json['status']?.toString() ?? 'Pending',
      timeAgo: 'Recent',
    );
  }
}
