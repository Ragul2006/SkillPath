/// Model representing a vocational trade / course
class Trade {
  final String id;
  final String name;
  final String nameTamil;
  final String? description;
  final String? descriptionTamil;
  final int nsqfLevel;
  final String sector;
  final List<String> skills;

  const Trade({
    required this.id,
    required this.name,
    required this.nameTamil,
    this.description,
    this.descriptionTamil,
    this.nsqfLevel = 4,
    required this.sector,
    this.skills = const [],
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameTamil: json['name_tamil'] as String? ?? '',
      description: json['description'] as String?,
      descriptionTamil: json['description_tamil'] as String?,
      nsqfLevel: (json['nsqf_level'] as num?)?.toInt() ?? 4,
      sector: json['sector'] as String? ?? 'General',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_tamil': nameTamil,
      'description': description,
      'description_tamil': descriptionTamil,
      'nsqf_level': nsqfLevel,
      'sector': sector,
      'skills': skills,
    };
  }

  /// Helper to get localized name
  String localizedName(String languageCode) {
    if (languageCode == 'ta' && nameTamil.isNotEmpty) {
      return nameTamil;
    }
    return name;
  }
}
