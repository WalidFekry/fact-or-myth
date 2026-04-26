import 'package:share_plus/share_plus.dart';
import '../../data/models/question_model.dart';

class ShareUtils {
  static Future<void> shareQuestion(QuestionModel question, {bool? userAnswer}) async {
    final answerText = question.correctAnswer ? 'حقيقة ✅' : 'خرافة ❌';
    
    String shareText = '🧠 حقيقة ولا خرافة؟\n\n';
    shareText += '${question.question}\n\n';
    shareText += 'الإجابة: $answerText\n\n';
    
    if (userAnswer != null) {
      final isCorrect = userAnswer == question.correctAnswer;
      shareText += isCorrect ? 'أجبت صح! 🎉\n\n' : 'أجبت خطأ 😅\n\n';
    }
    
    shareText += 'التفسير: ${question.explanation}\n\n';
    shareText += '📱 جرب التطبيق الآن!\n';
    shareText += 'حقيقة ولا خرافة - اختبر معلوماتك اليومية';

    await Share.share(
      shareText,
      subject: 'حقيقة ولا خرافة؟',
    );
  }

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
}
