/// Model representing human counsellor escalation request
class Escalation {
  final String? id;
  final String userId;
  final String? conversationId;
  final String? assignedCounsellor;
  final String reason;
  final String priority;
  final String status;
  final String? resolution;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  const Escalation({
    this.id,
    required this.userId,
    this.conversationId,
    this.assignedCounsellor,
    required this.reason,
    this.priority = 'Medium',
    this.status = 'Pending',
    this.resolution,
    this.createdAt,
    this.resolvedAt,
  });

  factory Escalation.fromJson(Map<String, dynamic> json) {
    return Escalation(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      conversationId: json['conversation_id'] as String?,
      assignedCounsellor: json['assigned_counsellor'] as String?,
      reason: json['reason'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      status: json['status'] as String? ?? 'Pending',
      resolution: json['resolution'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'conversation_id': conversationId,
      'assigned_counsellor': assignedCounsellor,
      'reason': reason,
      'priority': priority,
      'status': status,
      'resolution': resolution,
    };
  }
}
