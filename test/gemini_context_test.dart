import 'package:flutter_test/flutter_test.dart';
import 'package:skillpath/core/services/counselling_service.dart';

void main() {
  group('CounsellingService Intent & Context Tests', () {
    test('detectIntent identifies trade_search for automotive repair', () {
      final intent = CounsellingService.detectIntent('automotive repair');
      expect(intent, 'trade_search');
    });

    test('detectIntent identifies salary inquiries', () {
      final intent = CounsellingService.detectIntent('மாதம் எவ்வளவு சம்பளம் கிடைக்கும்?');
      expect(intent, 'salary');
    });

    test('detectIntent identifies degree comparison', () {
      final intent = CounsellingService.detectIntent('Degree படிக்கிறதா அல்லது vocational course படிக்கிறதா?');
      expect(intent, 'degree_comparison');
    });

    test('detectIntent identifies training provider inquiries', () {
      final intent = CounsellingService.detectIntent('சேலம் மாவட்டத்தில் ITI கல்லூரி உள்ளதா?');
      expect(intent, 'training_provider');
    });

    test('searchDatabaseGrounding finds Automotive Mechanic for automotive repair', () async {
      final grounding = await CounsellingService.searchDatabaseGrounding(
        'automotive repair',
        'trade_search',
      );
      final names = grounding['matching_trade_names'] as String;
      expect(names.contains('Automotive'), true);
      final text = grounding['grounding_text'] as String;
      expect(text.contains('Automotive'), true);
    });
  });
}
