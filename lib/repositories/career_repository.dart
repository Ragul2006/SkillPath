import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';
import '../models/outcome.dart';
import '../models/trade.dart';

/// Repository handling career, trade, and outcome data fetching
class CareerRepository {
  /// Fetch all vocational trades
  static Future<List<Trade>> getTrades({String? sector, String? query}) async {
    try {
      var builder = SupabaseService.trades.select('*');
      if (sector != null && sector != 'All' && sector.isNotEmpty) {
        builder = builder.ilike('sector', '%$sector%');
      }
      if (query != null && query.isNotEmpty) {
        builder = builder.ilike('name', '%$query%');
      }

      final data = await builder.order('name');
      final list = (data as List<dynamic>)
          .map((item) => Trade.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('Error fetching trades from Supabase: $e');
    }

    // Resilient fallback demo dataset
    return _demoTrades.where((t) {
      final matchesSector = sector == null || sector == 'All' || t.sector.toLowerCase() == sector.toLowerCase();
      final matchesQuery = query == null || query.isEmpty || t.name.toLowerCase().contains(query.toLowerCase()) || t.nameTamil.contains(query);
      return matchesSector && matchesQuery;
    }).toList();
  }

  /// Fetch outcome data for a specific trade
  static Future<Outcome?> getOutcomeForTrade(String tradeId) async {
    try {
      final data = await SupabaseService.outcomes
          .select('*')
          .eq('trade_id', tradeId)
          .limit(1);

      if ((data as List).isNotEmpty) {
        return Outcome.fromJson(Map<String, dynamic>.from(data.first as Map));
      }
    } catch (e) {
      debugPrint('Error fetching outcome: $e');
    }

    return _demoOutcomes[tradeId];
  }

  /// Fetch career progression path steps for a trade
  static Future<List<Map<String, dynamic>>> getCareerPath(String tradeId) async {
    try {
      final data = await SupabaseService.careerPaths
          .select('*')
          .eq('trade_id', tradeId)
          .order('step_number');

      final list = (data as List<dynamic>).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('Error fetching career path: $e');
    }

    return _demoPaths[tradeId] ?? [
      {'step_number': 1, 'title': 'Vocational Training', 'title_tamil': 'தொழிற்பயிற்சி', 'description': '1-2 years ITI certification.'},
      {'step_number': 2, 'title': 'Junior Technician', 'title_tamil': 'இளநிலை தொழில்நுட்பவியலாளர்', 'description': 'Entry-level industrial role.'},
      {'step_number': 3, 'title': 'Senior Specialist', 'title_tamil': 'முதுநிலை நிபுணர்', 'description': '2-4 years industry experience.'},
      {'step_number': 4, 'title': 'Floor Supervisor', 'title_tamil': 'மேற்பார்வையாளர்', 'description': 'Team leadership & operations.'},
    ];
  }

  static final List<Trade> _demoTrades = [
    const Trade(
      id: 'b305221c-43db-4cc9-b7b5-0c58e727dbf8',
      name: 'CNC Operator',
      nameTamil: 'CNC ஆப்பரேட்டர்',
      description: 'Operates computer numerical control machines to fabricate parts.',
      descriptionTamil: 'பாகங்களை உருவாக்க கணினி எண் கட்டுப்பாட்டு இயந்திரங்களை இயக்குகிறார்.',
      nsqfLevel: 4,
      sector: 'Manufacturing',
      skills: ['CAD/CAM', 'Blueprint Reading', 'Quality Inspection', 'Machine Tooling'],
    ),
    const Trade(
      id: '5de5837d-1db9-4089-a2e6-7313bd855cca',
      name: 'Electrician',
      nameTamil: 'எலக்ட்ரீஷியன்',
      description: 'Installs, maintains, and repairs electrical wiring and equipment.',
      descriptionTamil: 'மின் இணைப்புகள், உபகரணங்கள் மற்றும் சாதனங்களை நிறுவி பராமரிக்கிறார்.',
      nsqfLevel: 4,
      sector: 'Construction',
      skills: ['Circuit Wiring', 'Safety Protocols', 'Switchgear', 'Troubleshooting'],
    ),
    const Trade(
      id: '0eec711a-0e9e-4eec-893c-2374e5088eb4',
      name: 'Solar Technician',
      nameTamil: 'சோலார் டெக்னீஷியன்',
      description: 'Installs and maintains solar panel systems and inverters.',
      descriptionTamil: 'சூரிய ஒளி தகடு அமைப்புகளை நிறுவி பராமரிக்கிறார்.',
      nsqfLevel: 4,
      sector: 'Renewable Energy',
      skills: ['PV Cell Installation', 'Grid Connection', 'Inverter Servicing'],
    ),
    const Trade(
      id: '6b22b10a-d8cb-40ac-a2e3-6a3f1ed16fde',
      name: 'Fitter',
      nameTamil: 'ஃபிட்டர்',
      description: 'Assembles and fits fabricated parts into heavy industrial machinery.',
      descriptionTamil: 'உருவாக்கப்பட்ட பாகங்களை தயாரிப்புகளில் இணைத்து அமைக்கிறார்.',
      nsqfLevel: 4,
      sector: 'Manufacturing',
      skills: ['Bench Fitting', 'Lathe Operations', 'Grinding', 'Assembly'],
    ),
    const Trade(
      id: 'a1111111-1111-1111-1111-111111111111',
      name: 'Welder',
      nameTamil: 'வெல்டர்',
      description: 'Joins metal parts using TIG, MIG, and arc welding processes.',
      descriptionTamil: 'பல்வேறு வெல்டிங் நுட்பங்களைப் பயன்படுத்தி உலோக பாகங்களை இணைக்கிறார்.',
      nsqfLevel: 3,
      sector: 'Manufacturing',
      skills: ['Arc Welding', 'TIG/MIG', 'Fabrication', 'Safety Precautions'],
    ),
    const Trade(
      id: 'a2222222-2222-2222-2222-222222222222',
      name: 'Automotive Mechanic',
      nameTamil: 'ஆட்டோமோட்டிவ் மெக்கானிக்',
      description: 'Inspects, maintains, and repairs passenger cars and commercial vehicles.',
      descriptionTamil: 'வாகனங்களை பரிசோதித்து, பராமரித்து பழுது நீக்குகிறார்.',
      nsqfLevel: 4,
      sector: 'Automotive',
      skills: ['Engine Diagnosis', 'Brake Systems', 'EV Maintenance', 'Transmission'],
    ),
  ];

  static final Map<String, Outcome> _demoOutcomes = {
    'b305221c-43db-4cc9-b7b5-0c58e727dbf8': const Outcome(
      tradeId: 'b305221c-43db-4cc9-b7b5-0c58e727dbf8',
      district: 'Salem',
      placementRate: 82,
      minSalary: 16000,
      maxSalary: 20000,
      averageSalary: 18000,
      sampleSize: 420,
    ),
    '5de5837d-1db9-4089-a2e6-7313bd855cca': const Outcome(
      tradeId: '5de5837d-1db9-4089-a2e6-7313bd855cca',
      district: 'Coimbatore',
      placementRate: 85,
      minSalary: 15000,
      maxSalary: 22000,
      averageSalary: 17500,
      sampleSize: 500,
    ),
    '0eec711a-0e9e-4eec-893c-2374e5088eb4': const Outcome(
      tradeId: '0eec711a-0e9e-4eec-893c-2374e5088eb4',
      district: 'Chennai',
      placementRate: 90,
      minSalary: 18000,
      maxSalary: 28000,
      averageSalary: 21000,
      sampleSize: 310,
    ),
    '6b22b10a-d8cb-40ac-a2e3-6a3f1ed16fde': const Outcome(
      tradeId: '6b22b10a-d8cb-40ac-a2e3-6a3f1ed16fde',
      district: 'Salem',
      placementRate: 78,
      minSalary: 14000,
      maxSalary: 19000,
      averageSalary: 16000,
      sampleSize: 380,
    ),
  };

  static final Map<String, List<Map<String, dynamic>>> _demoPaths = {
    'b305221c-43db-4cc9-b7b5-0c58e727dbf8': [
      {'step_number': 1, 'title': 'Vocational Training', 'title_tamil': 'தொழிற்பயிற்சி', 'description': 'Complete 1-2 years of ITI CNC training.'},
      {'step_number': 2, 'title': 'Junior CNC Operator', 'title_tamil': 'இளநிலை CNC ஆப்பரேட்டர்', 'description': 'Entry-level machining under supervision.'},
      {'step_number': 3, 'title': 'Senior CNC Operator', 'title_tamil': 'முதுநிலை CNC ஆப்பரேட்டர்', 'description': '2-4 years experience with tool programming.'},
      {'step_number': 4, 'title': 'Shift Supervisor', 'title_tamil': 'சிப்ட் சூப்பர்வைசர்', 'description': 'Lead plant floor shift & production planning.'},
    ],
  };
}
