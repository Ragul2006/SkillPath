/// Model representing verified placement & salary outcome data
class Outcome {
  final String? id;
  final String tradeId;
  final String? providerId;
  final String? district;
  final int placementRate;
  final int minSalary;
  final int maxSalary;
  final int averageSalary;
  final int sampleSize;
  final int dataYear;
  final bool verified;
  final String source;

  const Outcome({
    this.id,
    required this.tradeId,
    this.providerId,
    this.district,
    required this.placementRate,
    required this.minSalary,
    required this.maxSalary,
    required this.averageSalary,
    this.sampleSize = 100,
    this.dataYear = 2026,
    this.verified = true,
    this.source = 'Hackathon Demo Dataset',
  });

  factory Outcome.fromJson(Map<String, dynamic> json) {
    return Outcome(
      id: json['id'] as String?,
      tradeId: json['trade_id'] as String? ?? '',
      providerId: json['provider_id'] as String?,
      district: json['district'] as String?,
      placementRate: (json['placement_rate'] as num?)?.toInt() ?? 0,
      minSalary: (json['min_salary'] as num?)?.toInt() ?? 0,
      maxSalary: (json['max_salary'] as num?)?.toInt() ?? 0,
      averageSalary: (json['average_salary'] as num?)?.toInt() ?? 0,
      sampleSize: (json['sample_size'] as num?)?.toInt() ?? 100,
      dataYear: (json['data_year'] as num?)?.toInt() ?? 2026,
      verified: json['verified'] as bool? ?? true,
      source: json['source'] as String? ?? 'Hackathon Demo Dataset',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'trade_id': tradeId,
      'provider_id': providerId,
      'district': district,
      'placement_rate': placementRate,
      'min_salary': minSalary,
      'max_salary': maxSalary,
      'average_salary': averageSalary,
      'sample_size': sampleSize,
      'data_year': dataYear,
      'verified': verified,
      'source': source,
    };
  }

  String get formattedSalaryRange => '₹${minSalary.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} - ₹${maxSalary.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  String get formattedPlacementRate => '$placementRate%';
}
