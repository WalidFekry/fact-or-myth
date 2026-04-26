import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../data/models/question_model.dart';

class ShareUtils {
  static Future<void> shareResult({
    required String questionText,
    required bool correctAnswer,
    required String explanation,
    required bool userAnswer,
    required bool isCorrect,
  }) async {
    final answerText = correctAnswer ? 'حقيقة ✅' : 'خرافة ❌';
    final resultEmoji = isCorrect ? '🎉' : '😅';
    
    String shareText = '🧠 حقيقة ولا خرافة؟\n\n';
    shareText += '$questionText\n\n';
    shareText += 'الإجابة: $answerText\n';
    shareText += isCorrect ? 'أجبت صح! $resultEmoji\n\n' : 'أجبت خطأ $resultEmoji\n\n';
    shareText += 'التفسير: $explanation\n\n';
    shareText += '📱 جرب التطبيق الآن!\n';
    shareText += 'حقيقة ولا خرافة - اختبر معلوماتك اليومية';

    await Share.share(
      shareText,
      subject: 'حقيقة ولا خرافة؟',
    );
  }

  // TASK 1: Copy question content to clipboard
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
    copyText += '📱 حقيقة ولا خرافة - اختبر معلوماتك اليومية';

    await Clipboard.setData(ClipboardData(text: copyText));
  }

  // Share question content (for free questions)
  static Future<void> shareQuestionContent({
    required String questionText,
    required bool correctAnswer,
    required String explanation,
  }) async {
    final answerText = correctAnswer ? 'حقيقة ✅' : 'خرافة ❌';
    
    String shareText = '🧠 حقيقة ولا خرافة؟\n\n';
    shareText += '$questionText\n\n';
    shareText += 'الإجابة: $answerText\n\n';
    shareText += 'التفسير: $explanation\n\n';
    shareText += '📱 جرب التطبيق الآن!\n';
    shareText += 'حقيقة ولا خرافة - اختبر معلوماتك اليومية';

    await Share.share(
      shareText,
      subject: 'حقيقة ولا خرافة؟',
    );
  }
}
