import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../services/supabase_service.dart';
import '../../repositories/career_repository.dart';

/// Service managing AI counselling sessions, conversation persistence in Supabase,
/// concern detection, sentiment event logging, and human counsellor escalation.
class CounsellingService {
  CounsellingService._();

  /// Retrieve existing active conversation for user, or create a new one.
  /// Ensures conversation_id remains constant throughout a counselling session.
  static Future<String> getOrCreateActiveConversation({
    required String userId,
    String language = 'ta',
  }) async {
    try {
      final existing = await SupabaseService.conversations
          .select('id, language')
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1);

      if ((existing as List).isNotEmpty) {
        final convId = existing.first['id'].toString();
        debugPrint('[SkillPath] Reusing active conversation: $convId');
        return convId;
      }

      // Create new conversation session in Supabase
      final response = await SupabaseService.conversations
          .insert({
            'user_id': userId,
            'language': language,
            'status': 'active',
          })
          .select('id')
          .single();

      final convId = response['id']?.toString() ?? 'local_conv_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[SkillPath] Started new conversation in Supabase: $convId');
      return convId;
    } catch (e) {
      debugPrint('[SkillPath] Warning: Could not create conversation in Supabase: $e');
      return 'local_conv_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Start a new conversation explicitly (e.g. user taps "New Session")
  static Future<String> startConversation({
    required String userId,
    String language = 'ta',
  }) async {
    return getOrCreateActiveConversation(userId: userId, language: language);
  }

  /// Retrieve conversation history from public.messages ordered by created_at ASC
  static Future<List<Map<String, dynamic>>> getConversationHistory(
    String conversationId, {
    int limit = 25,
  }) async {
    if (conversationId.startsWith('local_conv_')) {
      return [];
    }

    try {
      final data = await SupabaseService.messages
          .select('id, sender, message, intent, created_at')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .limit(limit);

      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      debugPrint('[SkillPath] Error fetching conversation history: $e');
      return [];
    }
  }

  /// Store a single chat message (voice transcript or text fallback) into Supabase
  static Future<void> saveMessage({
    required String conversationId,
    required String sender, // 'learner', 'parent', 'ai', 'system', 'counsellor'
    required String message,
    String? intent,
  }) async {
    if (conversationId.startsWith('local_conv_')) {
      debugPrint('[SkillPath] Skipping remote save for local test conversation');
      return;
    }

    try {
      await SupabaseService.messages.insert({
        'conversation_id': conversationId,
        'sender': sender,
        'message': message,
        'intent': intent,
      });
      debugPrint('[SkillPath] Saved message from $sender to conversation $conversationId');
    } catch (e) {
      debugPrint('[SkillPath] Error saving message to Supabase: $e');
    }
  }

  /// Detect user intent from input text
  static String detectIntent(String message) {
    final q = message.toLowerCase();

    // 1. Salary / Income
    if (q.contains('salary') ||
        q.contains('மாதம்') ||
        q.contains('சம்பளம்') ||
        q.contains('earn') ||
        q.contains('income') ||
        q.contains('pay') ||
        q.contains('package')) {
      return 'salary';
    }

    // 2. Placement / Job Security
    if (q.contains('placement') ||
        q.contains('வேலை வாய்ப்பு') ||
        q.contains('வேலை கிடைக்குமா') ||
        q.contains('job chance') ||
        q.contains('hire')) {
      return 'placement';
    }

    // 3. Training provider / Institutes / District
    if (q.contains('institute') ||
        q.contains('iti') ||
        q.contains('center') ||
        q.contains('மையம்') ||
        q.contains('பயிற்சி மையம்') ||
        q.contains('provider') ||
        q.contains('எங்கு') ||
        q.contains('district') ||
        q.contains('school')) {
      return 'training_provider';
    }

    // 4. Degree comparison
    if (q.contains('degree') ||
        q.contains('diploma') ||
        q.contains('டிகிரி') ||
        q.contains('கல்லூரி') ||
        q.contains('b.e') ||
        q.contains('polytechnic') ||
        q.contains('engineering')) {
      return 'degree_comparison';
    }

    // 5. Career growth / Path
    if (q.contains('growth') ||
        q.contains('progression') ||
        q.contains('future') ||
        q.contains('அடுத்தது') ||
        q.contains('முன்னேற்றம்') ||
        q.contains('supervisor') ||
        q.contains('promotion') ||
        q.contains('path')) {
      return 'career_growth';
    }

    // 6. Safety
    if (q.contains('safe') ||
        q.contains('பாதுகாப்பு') ||
        q.contains('danger') ||
        q.contains('hazard') ||
        q.contains('risk') ||
        q.contains('injury')) {
      return 'safety';
    }

    // 7. Course Cost / Fees
    if (q.contains('fee') ||
        q.contains('cost') ||
        q.contains('கட்டணம்') ||
        q.contains('செலவு') ||
        q.contains('scholarship')) {
      return 'course_cost';
    }

    // 8. Higher Education / Lateral Entry
    if (q.contains('higher education') ||
        q.contains('m.tech') ||
        q.contains('lateral') ||
        q.contains('மேற்படிப்பு')) {
      return 'higher_education';
    }

    // 9. Job Security
    if (q.contains('security') ||
        q.contains('permanent') ||
        q.contains('நிரந்தர') ||
        q.contains('stigma')) {
      return 'job_security';
    }

    // 10. Trade Search / Vocation query
    if (q.contains('automotive') ||
        q.contains('repair') ||
        q.contains('mechanic') ||
        q.contains('car') ||
        q.contains('vehicle') ||
        q.contains('cnc') ||
        q.contains('electri') ||
        q.contains('solar') ||
        q.contains('weld') ||
        q.contains('fitter') ||
        q.contains('plumber') ||
        q.contains('course') ||
        q.contains('trade') ||
        q.contains('படிப்பு') ||
        q.contains('தொழில்')) {
      return 'trade_search';
    }

    return 'general_counselling';
  }

  /// Perform factual database grounding query across public.trades, outcomes,
  /// career_roles, career_paths, and training_providers
  static Future<Map<String, dynamic>> searchDatabaseGrounding(
    String query,
    String intent, {
    String? district,
  }) async {
    final cleanQ = query.toLowerCase().trim();
    List<Map<String, dynamic>> matchingTrades = [];

    // Search keywords mapping
    String searchTerm = cleanQ;
    if (cleanQ.contains('automotive') || cleanQ.contains('repair') || cleanQ.contains('mechanic') || cleanQ.contains('car')) {
      searchTerm = 'Automotive';
    } else if (cleanQ.contains('cnc')) {
      searchTerm = 'CNC';
    } else if (cleanQ.contains('electri') || cleanQ.contains('மின்')) {
      searchTerm = 'Electrician';
    } else if (cleanQ.contains('solar') || cleanQ.contains('சூரிய')) {
      searchTerm = 'Solar';
    } else if (cleanQ.contains('weld')) {
      searchTerm = 'Welder';
    } else if (cleanQ.contains('fitter')) {
      searchTerm = 'Fitter';
    }

    try {
      final tradesData = await SupabaseService.trades
          .select('*')
          .or('name.ilike.%$searchTerm%,sector.ilike.%$searchTerm%,description.ilike.%$searchTerm%')
          .limit(3);

      if ((tradesData as List).isNotEmpty) {
        matchingTrades = List<Map<String, dynamic>>.from(tradesData);
      }
    } catch (e) {
      debugPrint('[SkillPath] Supabase trade query warning: $e');
    }

    // Fallback to local verified trades if remote returns empty
    if (matchingTrades.isEmpty) {
      final demoList = await CareerRepository.getTrades(query: searchTerm);
      matchingTrades = demoList.map((t) => t.toJson()).toList();
    }

    final StringBuffer groundingBuf = StringBuffer();
    final List<String> tradeNames = [];

    for (final trade in matchingTrades) {
      final tradeId = trade['id']?.toString() ?? '';
      final tradeName = trade['name']?.toString() ?? '';
      final tradeTamil = trade['name_tamil']?.toString() ?? '';
      tradeNames.add(tradeName);

      groundingBuf.writeln('TRADE: $tradeName ($tradeTamil)');
      groundingBuf.writeln('Sector: ${trade['sector']} | NSQF Level: ${trade['nsqf_level']}');
      if (trade['skills'] != null) {
        groundingBuf.writeln('Skills: ${trade['skills']}');
      }
      if (trade['description'] != null) {
        groundingBuf.writeln('Description: ${trade['description']}');
      }

      // Fetch verified outcomes
      try {
        final outcomeData = await SupabaseService.outcomes
            .select('*')
            .eq('trade_id', tradeId)
            .limit(1);

        if ((outcomeData as List).isNotEmpty) {
          final o = outcomeData.first;
          groundingBuf.writeln('Outcomes (Demo data): Placement Rate: ${o['placement_rate']}%, Salary Range: ₹${o['min_salary']} - ₹${o['max_salary']} (Avg: ₹${o['average_salary']}/month)');
        }
      } catch (_) {}

      // Fetch career progression paths
      try {
        final pathsData = await SupabaseService.careerPaths
            .select('*')
            .eq('trade_id', tradeId)
            .order('step_number')
            .limit(4);

        if ((pathsData as List).isNotEmpty) {
          groundingBuf.writeln('Career Progression Steps:');
          for (final p in pathsData) {
            groundingBuf.writeln('  Step ${p['step_number']}: ${p['title']} - ${p['description']}');
          }
        }
      } catch (_) {}

      // Fetch career job roles
      try {
        final rolesData = await SupabaseService.careerRoles
            .select('*')
            .eq('trade_id', tradeId)
            .limit(4);

        if ((rolesData as List).isNotEmpty) {
          groundingBuf.writeln('Key Job Roles:');
          for (final r in rolesData) {
            groundingBuf.writeln('  - ${r['role_name']} (Experience: ${r['experience_required'] ?? 'Entry'})');
          }
        }
      } catch (_) {}

      groundingBuf.writeln('---');
    }

    if (matchingTrades.isEmpty) {
      groundingBuf.writeln('No specific verified trade records matched "$searchTerm".');
    }

    return {
      'matching_trade_names': tradeNames.join(', '),
      'grounding_text': groundingBuf.toString().trim(),
      'trades': matchingTrades,
    };
  }

  /// Primary AI Message Handler:
  /// Coordinates conversation_id, intent detection, Supabase message save,
  /// history retrieval, database search, Gemini request with strict grounding,
  /// logging all [SkillPath] lines, saving AI response, and returning the text.
  static Future<String> sendMessage({
    required String conversationId,
    required String userMessage,
    required String userRole, // 'parent' or 'learner'
    required String language, // 'ta' or 'en'
    String? userName,
    String? district,
    String? educationLevel,
  }) async {
    // 1. Technical Log: conversation_id
    debugPrint('[SkillPath] conversation_id: $conversationId');

    // 2. Technical Log: user message
    debugPrint('[SkillPath] user message: $userMessage');

    // 3. Detect Intent
    final intent = detectIntent(userMessage);
    debugPrint('[SkillPath] detected intent: $intent');

    // 4. Save User Message to public.messages
    await saveMessage(
      conversationId: conversationId,
      sender: userRole,
      message: userMessage,
      intent: intent,
    );

    // 5. Retrieve Relevant Previous Messages from the SAME conversation
    final history = await getConversationHistory(conversationId);
    debugPrint('[SkillPath] history count: ${history.length}');

    // 6. Perform Database Grounding Search
    debugPrint('[SkillPath] database search: $userMessage');
    final grounding = await searchDatabaseGrounding(userMessage, intent, district: district);
    final matchingTradeNames = grounding['matching_trade_names'] as String? ?? 'None';
    debugPrint('[SkillPath] matching trades: $matchingTradeNames');

    // 7. Formulate Context-Rich Gemini Prompt
    final historyBuffer = StringBuffer();
    // Exclude the message we just added so it acts as context prior to latest message
    final priorHistory = history.length > 1 ? history.sublist(0, history.length - 1) : <Map<String, dynamic>>[];
    for (final h in priorHistory) {
      final s = h['sender']?.toString() == 'ai' ? 'AI' : (userRole == 'parent' ? 'Parent' : 'Learner');
      historyBuffer.writeln('$s: ${h['message']}');
    }

    final prompt = _buildGeminiPrompt(
      systemPrompt: _centralSystemPrompt,
      userRole: userRole,
      userName: userName ?? (userRole == 'parent' ? 'Parent' : 'Learner'),
      district: district ?? 'Tamil Nadu',
      educationLevel: educationLevel ?? '10th/12th',
      language: language,
      historyText: historyBuffer.toString().trim(),
      groundingText: grounding['grounding_text'] as String? ?? '',
      latestUserMessage: userMessage,
    );

    debugPrint('[SkillPath] Gemini request created: (model: gemini-3.8-flash, tokens: ~${prompt.length ~/ 4})');

    // 8. Call Gemini REST API
    String aiReply = '';
    final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? dotenv.env['GEMINI_API_KEY'];

    if (apiKey != null && apiKey.isNotEmpty) {
      aiReply = await _callGeminiApi(apiKey: apiKey, prompt: prompt);
    }

    // 9. Intelligent context-aware fallback if Gemini API is unreachable
    if (aiReply.isEmpty) {
      debugPrint('[SkillPath] Using intelligent grounded fallback');
      aiReply = _generateContextualLocalReply(
        userMessage: userMessage,
        intent: intent,
        language: language,
        grounding: grounding,
        hasPriorHistory: priorHistory.isNotEmpty,
      );
    }

    debugPrint('[SkillPath] Gemini response: $aiReply');

    // 10. Save AI response into public.messages
    await saveMessage(
      conversationId: conversationId,
      sender: 'ai',
      message: aiReply,
      intent: intent,
    );
    debugPrint('[SkillPath] AI message saved: conversationId=$conversationId, sender=ai');

    return aiReply;
  }

  /// Call Gemini generateContent endpoint with automatic model fallback
  static Future<String> _callGeminiApi({
    required String apiKey,
    required String prompt,
  }) async {
    final models = ['gemini-3.8-flash', 'gemini-flash-latest'];

    for (final model in models) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [{'text': prompt}]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.7,
                  'maxOutputTokens': 400,
                }
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates.first['content']?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts.first['text'] as String?;
              if (text != null && text.trim().isNotEmpty) {
                return text.trim();
              }
            }
          }
        } else {
          debugPrint('[SkillPath] Gemini API model $model returned ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('[SkillPath] Error calling Gemini model $model: $e');
      }
    }

    return '';
  }

  /// Construct structured prompt enforcing conversation history, grounding, and tone
  static String _buildGeminiPrompt({
    required String systemPrompt,
    required String userRole,
    required String userName,
    required String district,
    required String educationLevel,
    required String language,
    required String historyText,
    required String groundingText,
    required String latestUserMessage,
  }) {
    return '''$systemPrompt

CURRENT USER PROFILE & ROLE:
User: $userName | Role: $userRole | District: $district | Education: $educationLevel
Target Language: ${language == 'ta' ? 'Tamil' : 'English'}

RELEVANT CONVERSATION HISTORY:
${historyText.isNotEmpty ? historyText : '[First message of session]'}

RELEVANT DATABASE INFORMATION:
${groundingText.isNotEmpty ? groundingText : 'No specific trade records found.'}

CRITICAL RESPONSE RULES:
1. If the user's latest message is a brief follow-up answer (such as "automotive repair"), DO NOT restart the conversation with an introduction like "Hello! I am SkillPath AI Career Counsellor...".
2. Respond naturally to their answer in conversational ${language == 'ta' ? 'Tamil' : 'English'}.
3. Acknowledge the chosen trade warmly, briefly highlight 1-2 key facts from the DATABASE INFORMATION above (do NOT invent statistics), and ask a helpful follow-up question (e.g. 10th or 12th qualification, practical hands-on interest).
4. If demo data is cited, mention: "குறிப்பு: இது SkillPath prototype-க்காக உருவாக்கப்பட்ட synthetic/demo data. இது அதிகாரப்பூர்வ அரசு புள்ளிவிவரம் அல்ல."
5. Keep response conversational and empathetic, around 2-4 sentences.

LATEST USER MESSAGE (Respond to this in light of the conversation history and database information above):
$latestUserMessage
''';
  }

  /// Central System Instructions for SkillPath AI Counsellor
  static const String _centralSystemPrompt = '''
You are SkillPath, an AI career counsellor for vocational education in Tamil Nadu, India.
You help learners and parents make informed career decisions.
You communicate in Tamil when the user speaks Tamil and English when the user speaks English.
You must be respectful, patient, non-judgmental, and easy to understand.
You are especially designed for parents who may have concerns about vocational education.
Common concerns include: Salary, Job security, Career growth, Social perception, Safety, Training quality, Distance, Further education, Whether a degree would be better.
Never insult or discourage degree education.
Never claim that vocational education is automatically better.
Never pressure a parent or learner into selecting a particular career.
Your job is to explain the available options and help the family make an informed decision.

IMPORTANT DATA RULE:
Never invent salary information, placement rates, provider information, government statistics, or career progression information.
Use SkillPath database tools whenever factual career information is needed.
If information is unavailable, clearly say that the information is not available.
If a database record is synthetic/demo data, clearly tell the user:
"குறிப்பு: இது SkillPath prototype-க்காக உருவாக்கப்பட்ட synthetic/demo data. இது அதிகாரப்பூர்வ அரசு புள்ளிவிவரம் அல்ல."

Use simple Tamil for parents with low digital familiarity.
Do not overload the user with technical terminology.
''';

  /// Fallback local generator if network is completely down
  static String _generateContextualLocalReply({
    required String userMessage,
    required String intent,
    required String language,
    required Map<String, dynamic> grounding,
    required bool hasPriorHistory,
  }) {
    final isTamil = language == 'ta' ||
        userMessage.contains(RegExp(r'[\u0B80-\u0BFF]')) ||
        userMessage.toLowerCase().contains('padika');

    final q = userMessage.toLowerCase();

    // Automotive repair follow up
    if (q.contains('automotive') || q.contains('repair') || q.contains('mechanic')) {
      if (isTamil) {
        return 'சரி. உங்கள் மகனுக்கு Automotive Repair (வாகன பழுதுபார்ப்பு & மெக்கானிக்) துறையில் ஆர்வம் இருக்கிறது என்று புரிகிறது.\n\nஅவருக்கு vehicle maintenance, engine work போன்ற practical வேலைகளில் ஆர்வம் இருக்கிறதா? மேலும், அவர் 10ஆம் வகுப்பு அல்லது 12ஆம் வகுப்பு முடித்திருக்கிறாரா?';
      } else {
        return 'Understood. Automotive Repair and Vehicle Mechanics is a vital vocational path. Does your child have an interest in practical hands-on vehicle maintenance and diagnostics? Also, has he completed 10th or 12th standard?';
      }
    }

    // Follow-up on CNC
    if (q.contains('cnc')) {
      if (isTamil) {
        return 'சரி. CNC Operator துறையில் ஆர்வம் இருப்பது நல்ல விஷயம். சேலம் மற்றும் கோயம்புத்தூர் தொழிற்பேட்டைகளில் இதற்கு நல்ல தேவை உள்ளது. அவர் இயந்திர இயக்கம் மற்றும் புரோகிராமிங் செய்ய விரும்புகிறாரா?';
      } else {
        return 'Understood. CNC Machining offers solid manufacturing careers in industrial clusters like Salem and Coimbatore. Does he enjoy machine tooling and practical workshop training?';
      }
    }

    // Degree vs Vocational
    if (intent == 'degree_comparison') {
      if (isTamil) {
        return 'உங்கள் கவலை புரிகிறது. தொழிற்கல்வி (Vocational) அல்லது பட்டப்படிப்பு (Degree) இரண்டுமே அவரவர் விருப்பத்தைப் பொறுத்து பயனுள்ளவை. தொழிற்கல்வி 1-2 ஆண்டுகளில் நேரடியாக செய்முறை பயிற்சியும் வேலைவாய்ப்பும் அளிக்கிறது; பின்னர் லேட்டரல் என்ட்ரி மூலம் பாலிடெக்னிக் அல்லது பி.இ பட்டப்படிப்பை தொடரலாம். உங்கள் மகனின் ஆர்வம் எதில் உள்ளது?';
      } else {
        return 'Both vocational education and traditional degree programmes have distinct advantages. Vocational training emphasizes hands-on practical skills with immediate job entry in 1-2 years, with lateral-entry options into engineering diplomas. What are your child\'s key interests?';
      }
    }

    // General follow-up response if history exists (do NOT restart!)
    if (hasPriorHistory) {
      if (isTamil) {
        return 'நீங்கள் குறிப்பிட்ட தகவலை கவனித்தேன். உங்கள் குடும்ப சூழ்நிலை மற்றும் மகனின் ஆர்வத்திற்கு ஏற்ப சரியான பயிற்சி மையங்கள் மற்றும் வேலை வாய்ப்புகளை அறிய, அவர் 10ஆம் அல்லது 12ஆம் வகுப்பு முடித்திருக்கிறாரா என்று கூற முடியுமா?';
      } else {
        return 'Thank you for sharing that context. To help tailor the career pathway and verified training centers, could you let me know if your child has completed 10th or 12th standard?';
      }
    }

    // Only if it's the very first message of a fresh session
    if (isTamil) {
      return 'வணக்கம்! நான் SkillPath AI தொழிற்கல்வி ஆலோசகர். தொழிற்பிரிவுகள் (Automotive, CNC, Electrician, Solar போன்றவை), ஆரம்பச் சம்பளம் மற்றும் எதிர்கால வளர்ச்சி குறித்து என்னிடம் பேசலாம்.';
    } else {
      return 'Hello! I am the SkillPath AI Career Counsellor. I can help your family evaluate verified vocational trades, salaries, training providers, and career progression.';
    }
  }

  /// Backward-compatible wrapper
  static Future<String> generateFallbackTextResponse({
    required String input,
    required String language,
    String? district,
  }) async {
    return sendMessage(
      conversationId: 'local_conv_${DateTime.now().millisecondsSinceEpoch}',
      userMessage: input,
      userRole: 'parent',
      language: language,
      district: district,
    );
  }

  /// Record a family or learner concern
  static Future<bool> recordConcern({
    required String userId,
    required String conversationId,
    required String category,
    required String description,
    String severity = 'medium',
  }) async {
    try {
      await SupabaseService.concerns.insert({
        'user_id': userId,
        'conversation_id': conversationId.startsWith('local_conv_') ? null : conversationId,
        'category': category,
        'description': description,
        'severity': severity,
        'status': 'open',
      });
      debugPrint('[SkillPath] Logged concern category: $category');
      return true;
    } catch (e) {
      debugPrint('[SkillPath] Error logging concern: $e');
      return false;
    }
  }

  /// Record a sentiment event during the session
  static Future<void> recordSentiment({
    required String conversationId,
    required String sentiment,
    double confidence = 0.85,
  }) async {
    if (conversationId.startsWith('local_conv_')) return;

    try {
      await SupabaseService.sentimentEvents.insert({
        'conversation_id': conversationId,
        'sentiment': sentiment,
        'confidence': confidence,
      });
      debugPrint('[SkillPath] Logged sentiment: $sentiment ($confidence)');
    } catch (e) {
      debugPrint('[SkillPath] Error logging sentiment: $e');
    }
  }

  /// Create an escalation to a human vocational counsellor
  static Future<bool> createEscalation({
    required String userId,
    required String conversationId,
    required String reason,
    String priority = 'Medium',
  }) async {
    try {
      await SupabaseService.escalations.insert({
        'user_id': userId,
        'conversation_id': conversationId.startsWith('local_conv_') ? null : conversationId,
        'reason': reason,
        'priority': priority,
        'status': 'Pending',
      });
      debugPrint('[SkillPath] Created human counsellor escalation for user: $userId');
      return true;
    } catch (e) {
      debugPrint('[SkillPath] Error creating escalation in Supabase: $e');
      return false;
    }
  }
}
