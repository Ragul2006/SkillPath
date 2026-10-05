/// Bilingual strings dictionary for SkillPath (English & Tamil)
class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'SkillPath',
      'tagline': 'Your Skills. Your Career. Your Path.',
      'explore_careers': 'Explore Careers',
      'ai_counsellor': 'AI Counsellor',
      'family_dashboard': 'Family Dashboard',
      'search_hint': 'Search trades, skills, industries...',
      'all': 'All',
      'placement_rate': 'Placement Rate',
      'avg_salary': 'Average Salary',
      'salary_range': 'Salary Range',
      'verified_data': 'Verified MSDE Data',
      'demo_notice': 'Demo dataset provided for hackathon evaluation.',
      'career_progression': 'Career Progression',
      'training_providers': 'Training Institutes',
      'talk_to_counsellor': 'Talk to AI Counsellor',
      'escalate_human': 'Request Human Counsellor',
      'settings': 'Settings',
      'language': 'Language',
      'low_literacy_mode': 'Audio-Visual Mode (Low Literacy)',
      'logout': 'Sign Out',
      'welcome_greeting': 'Welcome back,',
      'recommended_for_you': 'Recommended Careers',
      'parent_concerns': 'Family & Parent Concerns',
      'decision_readiness': 'Family Decision Readiness',
    },
    'ta': {
      'app_title': 'ஸ்கில்பாத்',
      'tagline': 'உங்கள் திறமை. உங்கள் தொழில். உங்கள் பாதை.',
      'explore_careers': 'தொழில்களை ஆராயுங்கள்',
      'ai_counsellor': 'AI வழிகாட்டி',
      'family_dashboard': 'குடும்ப வழிகாட்டுதல்',
      'search_hint': 'படிப்புகள், திறன்களை தேடுங்கள்...',
      'all': 'அனைத்தும்',
      'placement_rate': 'வேலைவாய்ப்பு விகிதம்',
      'avg_salary': 'சராசரி ஊதியம்',
      'salary_range': 'ஊதிய வரம்பு',
      'verified_data': 'சரிபார்க்கப்பட்ட MSDE தரவு',
      'demo_notice': 'ஹேக்கத்தான் மதிப்பீட்டிற்கான மாதிரி தரவுத்தொகுப்பு.',
      'career_progression': 'தொழில் வளர்ச்சிப் பாதை',
      'training_providers': 'பயிற்சி மையங்கள்',
      'talk_to_counsellor': 'AI உடன் பேசுங்கள்',
      'escalate_human': 'நேரடி ஆலோசகரை அணுகவும்',
      'settings': 'அமைப்புகள்',
      'language': 'மொழி (Language)',
      'low_literacy_mode': 'ஒலி-ஒளி முறை (எளிதான பயன்பாடு)',
      'logout': 'வெளியேறு',
      'welcome_greeting': 'வணக்கம்,',
      'recommended_for_you': 'உங்களுக்கான பரிந்துரைகள்',
      'parent_concerns': 'பெற்றோர் கவலைகள்',
      'decision_readiness': 'குடும்ப முடிவு நிலை',
    },
  };

  static String get(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}
