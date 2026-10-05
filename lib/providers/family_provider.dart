import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/concern.dart';
import '../repositories/family_repository.dart';

/// Provider for user concerns
final concernsProvider = FutureProvider.family<List<Concern>, String>(
  (ref, userId) async {
    return FamilyRepository.getConcerns(userId);
  },
);
