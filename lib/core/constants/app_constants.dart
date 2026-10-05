/// App-wide constants
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'SkillPath';
  static const String tagline = 'Your Skills. Your Career. Your Path.';
  static const String appVersion = '1.0.0';

  // ── Demo Data Label ──
  static const String demoDataLabel =
      'Demo dataset provided for hackathon evaluation.';
  static const String demoDataShort = 'Hackathon demo dataset';

  // ── User Roles ──
  static const String roleLearner = 'learner';
  static const String roleParent = 'parent';
  static const String roleCounsellor = 'counsellor';
  static const String roleAdmin = 'admin';

  // ── Escalation Statuses ──
  static const String statusPending = 'pending';
  static const String statusAssigned = 'assigned';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';

  // ── Concern Categories ──
  static const List<String> concernCategories = [
    'salary',
    'job_security',
    'social_status',
    'safety',
    'distance',
    'course_quality',
    'career_growth',
    'higher_education',
  ];

  // ── Education Levels ──
  static const List<String> educationLevels = [
    '8th Standard',
    '10th Standard',
    '12th Standard',
    'ITI',
    'Diploma',
    'Graduate',
    'Post Graduate',
  ];

  // ── Preferred Industries ──
  static const List<String> industries = [
    'Manufacturing',
    'Automotive',
    'Electronics',
    'Construction',
    'Healthcare',
    'IT & Networking',
    'Beauty & Wellness',
    'Renewable Energy',
    'HVAC & Refrigeration',
    'Plumbing',
  ];

  // ── Salary Expectations ──
  static const List<String> salaryRanges = [
    '₹8,000 – ₹12,000',
    '₹12,000 – ₹16,000',
    '₹16,000 – ₹20,000',
    '₹20,000 – ₹25,000',
    '₹25,000+',
  ];

  // ── Tamil Nadu Districts (demo) ──
  static const List<String> districts = [
    'Chennai',
    'Coimbatore',
    'Madurai',
    'Salem',
    'Tiruchirappalli',
    'Erode',
    'Tirunelveli',
    'Vellore',
    'Thoothukudi',
    'Thanjavur',
  ];

  // ── Animation Durations ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Layout ──
  static const double screenPadding = 20.0;
  static const double cardRadius = 16.0;
  static const double inputRadius = 12.0;
}
