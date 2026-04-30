class AppConstants {
  // App URLs
  static const String googlePlayUrl = 'https://play.google.com/store/apps/details?id=fact.or.myth';
  static const String iosUrl = 'https://play.google.com/store/apps/details?id=fact.or.myth';

  // API Base URL
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

  // Storage Keys - UI Preferences
  static const String keyExplanationFontSize = 'explanation_font_size';
  
  // Font Size Limits
  static const double minExplanationFontSize = 12.0;
  static const double defaultExplanationFontSize = 16.0;
  static const double maxExplanationFontSize = 30.0;
  
  // Report Reasons
  static const List<String> reportReasons = [
    'إجابة خاطئة',
    'شرح خاطئ',
    'خطأ إملائي',
    'سؤال خاطئ',
    'أخرى',
  ];
  
  // Categories
  static const List<String> categories = [
    'عشوائي',
    'صحة',
    'معلومات عامة',
    'دينية',
    'نفسية',
    'تغذية',
    'رياضة',
    'طب',
    'جسم الإنسان',
    'نوم',
    'خرافات مشهورة',
    'أساطير',
    'حقائق صادمة',
    'ألغاز',
    'اختراعات',
    'تكنولوجيا',
    'إنترنت',
    'علوم',
    'حيوانات',
    'نباتات',
    'بيئة',
    'طقس ومناخ',
    'حضارات',
    'دول وعواصم',
    'رياضيات',
    'اقتصاد',
    'تسويق',
    'طبخ',
    'مشروبات',
    'عادات يومية',
    'تربية أطفال',
    'تعليم',
    'اكتشافات',
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

// Smart feedback messages
  static final List<String> correctMessages = [
    'إجابتك صح.. 🔥',
    'تحليل ممتاز 👀',
    'أيوه كده 💪',
    'واضح إنك مركز 👀',
    'إجابة في الجون 🎯',
    'ممتاز جدًا 👏',
    'تركيز عالي 🔥',
    'صح الصح ✅',
    'أداء قوي 💪',
    'إجابة ذكية 👏',
    'واضح إنك فاهم 👀',
    'جاوبت بثقة 😎',
    'عاش جدًا 👏',
    'استمر كده 💯',
    'مستوى عالي 👑',
    'ما شاء الله عليك 👏',
    'إجابة من الآخر ✅',
    'برافو عليك 🎉',
    'مخك شغال 👀',
  ];

  static final List<String> wrongMessages = [
    'ناس كتير بتقع فيها 👀',
    'مش صح..💡',
    'خد بالك المرة الجاية 👌',
    'قريبة.. حاول تاني 🔄',
    'مش دي الإجابة 😅',
    'معلش حصل خير 👌',
    'ركّز أكتر المرة الجاية 👀',
    'دي كانت خادعة شوية 😏',
    'إجابة مش دقيقة 💡',
    'حاول مرة كمان 🔄',
    'ولا يهمك.. اللي بعده 🔥',
    'السؤال كان محتاج تركيز 👀',
    'مش المرة دي 😄',
    'قربت توصل 👌',
    'اختيار مش موفق 😅',
    'خليك مركز والجاي أفضل 💪',
    'دي بتلخبط ناس كتير 👀',
    'حاول تقرأ السؤال تاني 💡',
    'ولا يهمك.. كمل 🔥',
    'المحاولة الجاية أحسن 💪',
  ];
}
