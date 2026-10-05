import '../../models/trade.dart';

/// Intelligent recommendation engine calculating match score for learners
class RecommendationService {
  /// Calculate a percentage match score (0-100) between learner profile and a trade
  static int calculateMatchScore({
    required Trade trade,
    required List<String> learnerInterests,
    required List<String> learnerSkills,
    String? preferredIndustry,
  }) {
    double score = 50.0; // Baseline

    // Check industry/sector match (+25%)
    if (preferredIndustry != null && preferredIndustry.isNotEmpty) {
      if (trade.sector.toLowerCase().contains(preferredIndustry.toLowerCase())) {
        score += 25.0;
      }
    }

    // Check interests match (+15%)
    for (final interest in learnerInterests) {
      if (trade.name.toLowerCase().contains(interest.toLowerCase()) ||
          trade.sector.toLowerCase().contains(interest.toLowerCase()) ||
          (trade.description?.toLowerCase().contains(interest.toLowerCase()) ?? false)) {
        score += 15.0;
        break;
      }
    }

    // Check skills match (+15%)
    int skillMatches = 0;
    for (final skill in learnerSkills) {
      if (trade.skills.any((s) => s.toLowerCase().contains(skill.toLowerCase()))) {
        skillMatches++;
      }
    }
    score += (skillMatches * 7.5);

    return score.clamp(55.0, 98.0).round();
  }

  /// Generate explanations for why a trade is recommended
  static List<String> getMatchReasons({
    required Trade trade,
    required int matchScore,
  }) {
    final reasons = <String>[];
    if (matchScore >= 80) {
      reasons.add('High alignment with your technical interests and hands-on skills.');
    }
    reasons.add('Strong regional hiring demand in Tamil Nadu industrial clusters.');
    if (trade.nsqfLevel >= 4) {
      reasons.add('Recognized NSQF Level ${trade.nsqfLevel} certification with lateral diploma entry options.');
    }
    return reasons;
  }
}
