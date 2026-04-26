import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/assets.dart';
import '../../core/utils/share_utils.dart';
import '../../viewmodels/daily_question_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../widgets/answer_button.dart';
import '../../widgets/countdown_timer.dart';
import '../../widgets/skeleton_loading.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/register_dialog.dart';
import '../../widgets/voting_stats_widget.dart';
import '../../data/services/sound_service.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../about/about_screen.dart';
import 'comments_screen.dart';

class DailyQuestionScreen extends StatefulWidget {
  const DailyQuestionScreen({super.key});

  @override
  State<DailyQuestionScreen> createState() => _DailyQuestionScreenState();
}

class _DailyQuestionScreenState extends State<DailyQuestionScreen> {

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
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text('التحدي اليومي'),
            ],
          ),
          actions: [
            // Theme Toggle
            Consumer<ThemeViewModel>(
              builder: (context, themeVM, _) {
                return IconButton(
                  icon: Icon(
                    themeVM.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 22,
                  ),
                  onPressed: () => themeVM.toggleTheme(),
                  tooltip: themeVM.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
                );
              },
            ),
            // About Button
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
              child: Icon(
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

  Widget _buildQuestionContent(BuildContext context, DailyQuestionViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Countdown Timer at Top (if answered)
          if (vm.hasAnswered && vm.nextQuestionTime != null) ...[
            CountdownTimer(targetTime: vm.nextQuestionTime!),
            const SizedBox(height: 16),
          ],

          // Question Card
          _buildQuestionCard(context, vm),
          const SizedBox(height: 20),

          // Answer Buttons or Result
          if (!vm.hasAnswered)
            _buildAnswerButtons(vm)
          else
            _buildResultSection(context, vm),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, DailyQuestionViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Question Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_rounded,
                color: AppColors.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),

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

  Widget _buildAnswerButtons(DailyQuestionViewModel vm) {
    // Disable buttons during loading or if already answered
    final isEnabled = vm.canSubmitAnswer;
    final soundService = getIt<SoundService>();
    
    return Column(
      children: [
        AnswerButton(
          text: 'حقيقة ✓',
          isTrue: true,
          onPressed: isEnabled ? () async {
            await vm.submitAnswer(true);
            // Play sound after answer is submitted
            if (vm.isCorrect != null) {
              if (vm.isCorrect!) {
                soundService.playCorrectSound();
              } else {
                soundService.playWrongSound();
              }
            }
          } : () {},
        ),
        const SizedBox(height: 12),
        AnswerButton(
          text: 'خرافة ✗',
          isTrue: false,
          onPressed: isEnabled ? () async {
            await vm.submitAnswer(false);
            // Play sound after answer is submitted
            if (vm.isCorrect != null) {
              if (vm.isCorrect!) {
                soundService.playCorrectSound();
              } else {
                soundService.playWrongSound();
              }
            }
          } : () {},
        ),
        
        // Show loading indicator during submission
        if (vm.isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
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
        const SizedBox(height: 20),

        // Result Message
        if (vm.isCorrect != null && vm.resultMessage != null)
          _buildResultMessage(context, vm),

        if (vm.isCorrect != null && vm.resultMessage != null)
          const SizedBox(height: 16),

        // Explanation Card
        _buildExplanationCard(context, vm),

        const SizedBox(height: 16),

        // Voting Statistics
        if (vm.question!.totalVotes > 0)
          VotingStatsWidget(
            trueVotes: vm.question!.trueVotes,
            falseVotes: vm.question!.falseVotes,
          ),

        if (vm.question!.totalVotes > 0)
          const SizedBox(height: 16),

        // Action Buttons
        Consumer<AuthViewModel>(
          builder: (context, authVM, _) {
            if (!authVM.isLoggedIn) {
              // Guest user: Show registration prompt with tap action
              return GestureDetector(
                onTap: () async {
                  final registered = await showRegisterDialog(context);
                  if (registered == true && mounted) {
                    // Reload the screen or update state if needed
                    setState(() {});
                  }
                },
                child: Card(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add_rounded,
                          color: AppColors.primaryDark,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سجل حساب لحفظ نتائجك',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اضغط هنا للتسجيل',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

            return _buildActionButton(
              context,
              icon: Icons.comment_rounded,
              label: 'التعليقات',
              color: AppColors.secondaryDark,
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
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                vm.resultMessage!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            // Share Button
            IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
              onPressed: () {
                if (vm.question != null) {
                  ShareUtils.shareResult(
                    questionText: vm.question!.question,
                    correctAnswer: vm.question!.correctAnswer,
                    explanation: vm.question!.explanation,
                    userAnswer: vm.userAnswer!,
                    isCorrect: isCorrect,
                  );
                }
              },
              tooltip: 'مشاركة',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context, DailyQuestionViewModel vm) {
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
                  child: Icon(
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
              ],
            ),
            const SizedBox(height: 12),
            Text(
              vm.question!.explanation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
