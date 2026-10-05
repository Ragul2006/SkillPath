/// Model representing a parent or family concern
class Concern {
  final String? id;
  final String userId;
  final String? conversationId;
  final String category;
  final String description;
  final String severity;
  final String status;

  const Concern({
    this.id,
    required this.userId,
    this.conversationId,
    required this.category,
    required this.description,
    this.severity = 'medium',
    this.status = 'open',
  });

  factory Concern.fromJson(Map<String, dynamic> json) {
    return Concern(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      conversationId: json['conversation_id'] as String?,
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'open',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'conversation_id': conversationId,
      'category': category,
      'description': description,
      'severity': severity,
      'status': status,
    };
  }
}
