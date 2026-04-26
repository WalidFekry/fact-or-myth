class AppConstants {
  // API Base URL - CHANGE THIS TO YOUR SERVER
  static const String baseUrl = 'https://post.walid-fekry.com/fact-app/api';
  
  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserAvatar = 'user_avatar';
  static const String keyIsLoggedIn = 'is_logged_in';
  
  // Categories
  static const List<String> categories = [
    'عشوائي',
    'صحة',
    'معلومات عامة',
    'نفسية',
    'دينية',
  ];
  
  // Avatars (predefined list)
  static const List<String> avatars = [
    '👨',
    '👩',
    '🧔',
    '👴',
    '👵',
    '👦',
    '👧',
    '🧑',
    '👨‍💼',
    '👩‍💼',
    '👨‍🎓',
    '👩‍🎓',
    '👨‍⚕️',
    '👩‍⚕️',
    '👨‍🔬',
    '👩‍🔬',
  ];
  
  // Leaderboard
  static const int minAnswersForLeaderboard = 5;
  static const int leaderboardTopCount = 100;
  
  // Messages
  static const String msgCorrectAnswer = 'جاوبت صح! شوف ترتيبك 🔥';
  static const String msgWrongAnswer = 'مش لوحدك 😅 شوف ترتيب الناس';
  static const String msgNextQuestion = 'السؤال الجديد بعد:';
  static const String msgNewQuestion = 'سؤال جديد';
  static const String msgLoginRequired = 'يجب تسجيل الدخول أولاً';
}
