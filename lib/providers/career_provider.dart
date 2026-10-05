import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/outcome.dart';
import '../models/trade.dart';
import '../repositories/career_repository.dart';

/// Provider for trades filtered by sector and query
final tradesProvider = FutureProvider.family<List<Trade>, ({String? sector, String? query})>(
  (ref, filter) async {
    return CareerRepository.getTrades(sector: filter.sector, query: filter.query);
  },
);

/// Provider for all trades
final allTradesProvider = FutureProvider<List<Trade>>((ref) async {
  return CareerRepository.getTrades();
});

/// Provider for specific trade outcome
final tradeOutcomeProvider = FutureProvider.family<Outcome?, String>(
  (ref, tradeId) async {
    return CareerRepository.getOutcomeForTrade(tradeId);
  },
);

/// Provider for career path progression
final careerPathProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, tradeId) async {
    return CareerRepository.getCareerPath(tradeId);
  },
);
