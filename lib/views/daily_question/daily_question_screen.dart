import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/assets.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/share_utils.dart';
import '../../data/services/sound_service.dart';
import '../../data/services/storage_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/daily_question_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../widgets/answer_button.dart';
import '../../widgets/countdown_timer.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/modern_action_button.dart';
import '../../widgets/register_dialog.dart';
import '../../widgets/skeleton_loading.dart';
import '../../widgets/voting_stats_widget.dart';
import '../about/about_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../report/report_question_screen.dart';
import 'comments_screen.dart';

class DailyQuestionScreen extends StatefulWidget {
  const DailyQuestionScreen({super.key});

  @override
  State<DailyQuestionScreen> createState() => _DailyQuestionScreenState();
}

class _DailyQuestionScreenState extends State<DailyQuestionScreen> {
  // Font size state for explanation text
  double _explanationFontSize = AppConstants.defaultExplanationFontSize;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final storageService = getIt<StorageService>();
    setState(() {
      _explanationFontSize = storageService.getExplanationFontSize();
    });
  }

  void _increaseFontSize() {
    if (_explanationFontSize < AppConstants.maxExplanationFontSize) {
      setState(() {
        _explanationFontSize += 2;
      });
      _saveFontSize();
    }
  }

  void _decreaseFontSize() {
    if (_explanationFontSize > AppConstants.minExplanationFontSize) {
      setState(() {
        _explanationFontSize -= 2;
      });
      _saveFontSize();
    }
  }

  Future<void> _saveFontSize() async {
    final storageService = getIt<StorageService>();
    await storageService.saveExplanationFontSize(_explanationFontSize);
  }

  // Handle force logout
  void _handleForceLogout(BuildContext context) async {
    final authVM = context.read<AuthViewModel>();
    await authVM.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الخروج. يرجى تسجيل الدخول مرة أخرى'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<DailyQuestionViewModel>()..loadDailyQuestion(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  AppAssets.logo,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        size: 16,
                        color: AppColors.pureWhite,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text('حقيقة ولا خرافة؟'),
            ],
          ),
          actions: [
            // Theme Toggle
            Consumer<ThemeViewModel>(
              builder: (context, themeVM, _) {
                return IconButton(
                  icon: Icon(
                    themeVM.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 22,
                  ),
                  onPressed: () => themeVM.toggleTheme(),
                  tooltip: themeVM.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
                );
              },
            ), // About Button
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
              tooltip: 'عن التطبيق',
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<DailyQuestionViewModel>(
            builder: (context, vm, _) {
              // Handle force_logout
              if (vm.error == 'force_logout') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleForceLogout(context);
                });
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.isLoading) {
                return const QuestionSkeletonLoader();
              }

              if (vm.error != null) {
                return ErrorDisplayWidget(
                  message: vm.error!,
                  onRetry: vm.loadDailyQuestion,
                );
              }

              if (vm.question == null) {
                return _buildEmptyState(context);
              }

              return _buildQuestionContent(context, vm);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_rounded,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد سؤال اليوم',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'تحقق لاحقاً للحصول على سؤال جديد',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent(
      BuildContext context, DailyQuestionViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dynamic Greeting (only show before answering)
          if (!vm.hasAnswered) ...[
            _buildGreetingSection(context),
            const SizedBox(height: 10),
          ],
          // Question Card
          _buildQuestionCard(context, vm), const SizedBox(height: 10),
          // Answer Buttons or Result
          if (!vm.hasAnswered)
            _buildAnswerButtons(vm)
          else
            _buildResultSection(context, vm), // Countdown Timer if answered)
          if (vm.nextQuestionTime != null) ...[
            const SizedBox(height: 12),
            CountdownTimer(targetTime: vm.nextQuestionTime!),
          ],
        ],
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final userName = authVM.getUserName() ?? 'صديقي';

    return Card(
      color: AppColors.primaryDark.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '👋',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أهلاً يا $userName',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'جاهز لسؤال اليوم؟ 🔥',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, DailyQuestionViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Category Chip
            _buildCategoryChip(vm.question!.category),
            const SizedBox(height: 10),
            // Question Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_rounded,
                color: AppColors.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            // Question Text
            Text(
              vm.question!.question,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.category_rounded,
            size: 14,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButtons(DailyQuestionViewModel vm) {
    // Disable buttons during loading or if already answered
    final isEnabled = vm.canSubmitAnswer;
    final soundService = getIt<SoundService>();

    return Column(
      children: [
        AnswerButton(
          text: 'حقيقة ✓',
          isTrue: true,
          onPressed: isEnabled
              ? () async {
                  await vm.submitAnswer(true);
                  // Play sound after answer is submitted
                  if (vm.isCorrect != null) {
                    if (vm.isCorrect!) {
                      soundService.playCorrectSound();
                    } else {
                      soundService.playWrongSound();
                    }
                  }
                }
              : () {},
        ),
        const SizedBox(height: 12),
        AnswerButton(
          text: 'خرافة ✗',
          isTrue: false,
          onPressed: isEnabled
              ? () async {
                  await vm.submitAnswer(false);
                  // Play sound after answer is submitted
                  if (vm.isCorrect != null) {
                    if (vm.isCorrect!) {
                      soundService.playCorrectSound();
                    } else {
                      soundService.playWrongSound();
                    }
                  }
                }
              : () {},
        ),

        // Show loading indicator during submission
        if (vm.isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'جاري الإرسال...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryDark,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResultSection(BuildContext context, DailyQuestionViewModel vm) {
    return Column(
      children: [
        // Answer Buttons (disabled, showing result)
        AnswerButton(
          text: 'حقيقة ✓',
          isTrue: true,
          onPressed: () {},
          isSelected: vm.userAnswer == true,
          correctAnswer: vm.question!.correctAnswer,
        ),
        const SizedBox(height: 12),
        AnswerButton(
          text: 'خرافة ✗',
          isTrue: false,
          onPressed: () {},
          isSelected: vm.userAnswer == false,
          correctAnswer: vm.question!.correctAnswer,
        ),
        const SizedBox(height: 12),
        // Result Message
        if (vm.isCorrect != null && vm.resultMessage != null)
          _buildResultMessage(context, vm),
        if (vm.isCorrect != null && vm.resultMessage != null)
          const SizedBox(height: 12),
        // Explanation Card
        _buildExplanationCard(context, vm),
        const SizedBox(height: 12),
        // Voting Statistics
        if (vm.question!.totalVotes > 0)
          VotingStatsWidget(
            trueVotes: vm.question!.trueVotes,
            falseVotes: vm.question!.falseVotes,
          ),
        if (vm.question!.totalVotes > 0) const SizedBox(height: 12),
        // Action Buttons
        Consumer<AuthViewModel>(
          builder: (context, authVM, _) {
            if (!authVM.isLoggedIn) {
              // Guest user: Show registration prompt with tap action
              return GestureDetector(
                onTap: () async {
                  final registered = await showRegisterDialog(context);
                  if (registered == true && mounted) {
                    // Reload the question to show migrated answer
                    final dailyVM = context.read<DailyQuestionViewModel>();
                    await dailyVM.loadDailyQuestion();
                  }
                },
                child: Card(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_add_rounded,
                          color: AppColors.primaryDark,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سجل حساب لحفظ نتائجك',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اضغط هنا للتسجيل',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return ModernActionButton(
              icon: Icons.comment_rounded,
              label: 'التعليقات',
              color: AppColors.primaryDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentsScreen(
                      questionId: vm.question!.id,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultMessage(BuildContext context, DailyQuestionViewModel vm) {
    final isCorrect = vm.isCorrect!;

    return Card(
      color: isCorrect ? AppColors.success : AppColors.error,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: AppColors.pureWhite,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                vm.resultMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pureWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(
      BuildContext context, DailyQuestionViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'التفسير',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 16,
                      ),
                ),
                const Spacer(),
                // Font Size Controls
                _buildFontSizeButton(
                  icon: Icons.text_decrease_rounded,
                  label: 'A-',
                  onTap: _decreaseFontSize,
                  enabled: _explanationFontSize >
                      AppConstants.minExplanationFontSize,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_explanationFontSize.toInt()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                _buildFontSizeButton(
                  icon: Icons.text_increase_rounded,
                  label: 'A+',
                  onTap: _increaseFontSize,
                  enabled: _explanationFontSize <
                      AppConstants.maxExplanationFontSize,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              vm.question!.explanation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontSize: _explanationFontSize,
                  ),
            ),
            const SizedBox(height: 16),
            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: _buildIconButton(
                    context,
                    icon: Icons.share_rounded,
                    label: 'مشاركة',
                    onTap: () {
                      ShareUtils.shareResult(
                        questionText: vm.question!.question,
                        correctAnswer: vm.question!.correctAnswer,
                        explanation: vm.question!.explanation,
                        userAnswer: vm.userAnswer!,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildIconButton(
                    context,
                    icon: Icons.content_copy_rounded,
                    label: 'نسخ',
                    onTap: () {
                      ShareUtils.copyQuestionContent(
                          questionText: vm.question!.question,
                          correctAnswer: vm.question!.correctAnswer,
                          explanation: vm.question!.explanation);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ السؤال ✓'),
                            duration: Duration(seconds: 2),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildIconButton(
                    context,
                    icon: Icons.flag_rounded,
                    label: 'إبلاغ',
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReportQuestionScreen(
                            questionId: vm.question!.id,
                            questionText: vm.question!.question,
                            category: vm.question!.category,
                            source: 'daily',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              : (isDark
                  ? AppColors.surfaceDark.withOpacity(0.5)
                  : AppColors.surfaceLight.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled
                ? AppColors.primaryDark.withOpacity(0.3)
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: enabled
                  ? AppColors.primaryDark
                  : (isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? AppColors.primaryDark
                    : (isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.primaryDark;

    return Material(
      color: buttonColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: buttonColor, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: buttonColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
