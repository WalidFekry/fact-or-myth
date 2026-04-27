class AppConstants {
  // App URLs
  static const String googlePlayUrl = 'https://play.google.com/store/apps/details?id=fact.or.myth';
  static const String iosUrl = 'https://play.google.com/store/apps/details?id=fact.or.myth';

  // API Base URL - CHANGE THIS TO YOUR SERVER
  static const String baseUrl = 'https://post.walid-fekry.com/fact-or-myth/api';
  
  // Storage Keys - User Session
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserAvatar = 'user_avatar';
  static const String keyIsLoggedIn = 'is_logged_in';
  
  // Storage Keys - Onboarding & App State
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  
  // Storage Keys - Guest Mode
  static const String keyGuestQuestionId = 'guest_question_id';
  static const String keyGuestAnswer = 'guest_answer';
  static const String keyGuestIsCorrect = 'guest_is_correct';
  static const String keyGuestAnsweredDate = 'guest_answered_date';
  
  // Storage Keys - Daily Question Cache
  static const String keyCachedDailyQuestion = 'cached_daily_question';
  static const String keyCachedDailyQuestionTimestamp = 'cached_daily_question_timestamp';
  static const String keyDailyQuestionAnswer = 'daily_question_answer';
  
  // Storage Keys - Notifications
  static const String keyNotificationPermissionShown = 'notification_permission_shown';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyFCMToken = 'fcm_token';
  
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

  // Smart feedback messages
  static final List<String> correctMessages = [
    'دي فعلًا حقيقة 👌',
    'إجابتك صح.. دي حقيقة 100% 🔥',
    'معلومة مظبوطة ✔️ دي حقيقة',
    'تحليل ممتاز 👀 دي حقيقة فعلًا',
    'أيوه كده 💪 دي حقيقة مش خرافة',
    'واضح إنك مركز 👀',
  ];

  static final List<String> wrongMessages = [
    'دي خرافة مش حقيقة ❌',
    'المعلومة دي للأسف خرافة 😅',
    'ناس كتير بتقع فيها 👀 دي خرافة',
    'شكلها مقنعة بس دي خرافة 🤷‍♂️',
    'مش صح.. دي خرافة 💡',
    'خد بالك المرة الجاية 👌 دي خرافة',
  ];
}
