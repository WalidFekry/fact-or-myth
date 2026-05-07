import 'dart:io';

import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class ShareUtils {
  static Future<void> shareResult({
    required String questionText,
    required bool correctAnswer,
    required String explanation,
    required bool userAnswer,
  }) async {
    final answerText = correctAnswer ? 'حقيقة ✅' : 'خرافة ❌';

    String shareText = '🧠 حقيقة ولا خرافة؟\n\n';
    shareText += '$questionText\n\n';
    shareText += 'الإجابة: $answerText\n';
    shareText += 'التفسير: $explanation\n\n';
    shareText += 'حقيقة ولا خرافة - اختبر معلوماتك اليومية 📱';

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'حقيقة ولا خرافة؟',
      ),
    );
  }

  //Copy question content to clipboard
  static Future<void> copyQuestionContent({
    required String questionText,
    required bool correctAnswer,
    required String explanation,
  }) async {
    final answerText = correctAnswer ? 'حقيقة ✅' : 'خرافة ❌';
    
    String copyText = '🧠 حقيقة ولا خرافة؟\n\n';
    copyText += '$questionText\n\n';
    copyText += 'الإجابة: $answerText\n\n';
    copyText += 'التفسير: $explanation\n\n';
    copyText += 'حقيقة ولا خرافة - اختبر معلوماتك اليومية 📱';

    await Clipboard.setData(ClipboardData(text: copyText));
  }

  // Share full app (Android + iOS links)
  static Future<void> shareApp() async {
    String shareText = '🧠 حقيقة ولا خرافة؟\n\n';
    shareText += 'اختبر معلوماتك يوميًا بطريقة ممتعة وتنافس مع الآخرين 🔥\n\n';
    shareText += '📲 حمّل التطبيق الآن:\n';

    if (Platform.isAndroid) {
      shareText += '${AppConstants.googlePlayUrl}\n';
    } else if (Platform.isIOS) {
      shareText += '${AppConstants.iosUrl}\n';
    } else {
      shareText += '🤖 Google Play: ${AppConstants.googlePlayUrl}\n';
      shareText += '🍎 App Store: ${AppConstants.iosUrl}\n';
    }
    shareText += '\n🔥 جرّب التحدي اليومي وشوف مستواك!';
    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'حقيقة ولا خرافة؟',
      ),
    );
  }

  // Share Challenge with Friend
  static Future<void> shareChallenge({
    required dynamic question,
    required bool userAnswer,
    int? userId,
  }) async {
    final questionText = question.question as String;
    final questionId = question.id as int;

    String shareText = 'أنا اتحديتك في سؤال! 😏\n\n';
    shareText += 'هل دي حقيقة ولا خرافة؟ 🧠\n\n';
    shareText += '$questionText\n\n';
    shareText += 'جاوب وشوف مين فينا الصح 👇\n\n';
    
    // Deep link format
    shareText += 'https://walid-fekry.com/fact-or-myth/ch/$questionId';
    if(userId != null){
      shareText += '/$userId';
    }

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'تحدي: حقيقة ولا خرافة؟',
      ),
    );
  }

  // Open Store
  static Future<void> rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    inAppReview.openStoreListing(appStoreId: '');
  }
}
