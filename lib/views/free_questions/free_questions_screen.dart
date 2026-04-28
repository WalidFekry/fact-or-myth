import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/share_utils.dart';
import '../../data/services/sound_service.dart';
import '../../data/services/storage_service.dart';
import '../../viewmodels/free_questions_viewmodel.dart';
import '../../widgets/answer_button.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/modern_action_button.dart';
import '../../widgets/skeleton_loading.dart';
import '../report/report_question_screen.dart';

class FreeQuestionsScreen extends StatefulWidget {
  const FreeQuestionsScreen({super.key});

  @override
  State<FreeQuestionsScreen> createState() => _FreeQuestionsScreenState();
}

class _FreeQuestionsScreenState extends State<FreeQuestionsScreen> {
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

  void _showRefreshDialog(BuildContext context, FreeQuestionsViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('تحديث الأسئلة'),
        content: const Text(
          'سيتم تحميل أحدث الأسئلة من قاعدة البيانات إذا كانت متوفرة. هل تريد المتابعة؟',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.syncQuestions();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث الأسئلة بنجاح ✓'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, FreeQuestionsViewModel vm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.celebration_rounded,
              color: AppColors.success,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('أحسنت!'),
          ],
        ),
        content: Text(
          'انتهت الأسئلة في هذا القسم 👏\nلقد أجبت على ${vm.totalQuestionsCount} سؤال',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('اختيار قسم آخر'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.resetCategory();
              vm.loadQuestion();
            },
            child: const Text('إعادة من البداية'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<FreeQuestionsViewModel>()..loadQuestion(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'أسئلة حرة',
          showBack: false,
          actions: [
            Consumer<FreeQuestionsViewModel>(
              builder: (context, vm, _) {
                return Row(
                  children: [
                    // Offline/Online indicator
                    Icon(
                      vm.isOnline
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      color:
                          vm.isOnline ? AppColors.success : AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 4), // Sync button
                    if (vm.isOnline)
                      IconButton(
                        icon: vm.isSyncing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync_rounded, size: 22),
                        onPressed: vm.isSyncing
                            ? null
                            : () => _showRefreshDialog(context, vm),
                        tooltip: 'تحديث الأسئلة',
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<FreeQuestionsViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                // Offline mode banner
                if (!vm.isOnline && vm.question != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: AppColors.warning.withOpacity(0.15),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_off_rounded,
                            color: AppColors.warning, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'وضع عدم الاتصال - الأسئلة محفوظة محلياً',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Sync status
                if (vm.lastSyncTime != null)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'آخر تحديث: ${_formatSyncTime(vm.lastSyncTime!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Category Selector
                Container(
                  height: 52,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.categories.length,
                    itemBuilder: (context, index) {
                      final category = AppConstants.categories[index];
                      final isSelected = category == vm.selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            vm.setCategory(category);
                            vm.loadQuestion();
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Progress Indicator
                if (vm.shouldShowProgress)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${vm.totalQuestionsCount - vm.remainingQuestionsCount} / ${vm.totalQuestionsCount}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: vm.totalQuestionsCount > 0
                                  ? (vm.totalQuestionsCount -
                                          vm.remainingQuestionsCount) /
                                      vm.totalQuestionsCount
                                  : 0,
                              backgroundColor:
                                  AppColors.primaryDark.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryDark),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Question Content
                Expanded(
                  child: vm.isLoading
                      ? const QuestionSkeletonLoader()
                      : vm.error != null
                          ? ErrorDisplayWidget(
                              message: vm.error!,
                              onRetry: vm.isOnline ? vm.loadQuestion : null,
                            )
                          : vm.question == null
                              ? _buildEmptyState(context, vm)
                              : _buildQuestionContent(context, vm),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, FreeQuestionsViewModel vm) {
    // Check if category is completed
    if (vm.hasCompletedCategory()) {
      // Show completion dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompletionDialog(context, vm);
      });
    }

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
                vm.hasCompletedCategory()
                    ? Icons.celebration_rounded
                    : Icons.quiz_rounded,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vm.hasCompletedCategory()
                  ? 'انتهت الأسئلة في هذا القسم 👏'
                  : 'لا توجد أسئلة',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            if (!vm.isOnline && !vm.hasCompletedCategory()) ...[
              const SizedBox(height: 6),
              Text(
                'يرجى الاتصال بالإنترنت لتحميل الأسئلة',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent(
      BuildContext context, FreeQuestionsViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vm.question!.category,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
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
          ),
          const SizedBox(height: 10),
          // Answer Buttons or Result
          if (!vm.hasAnswered)
            _buildAnswerButtons(vm)
          else
            _buildResultSection(context, vm),
        ],
      ),
    );
  }

  Widget _buildAnswerButtons(FreeQuestionsViewModel vm) {
    final soundService = getIt<SoundService>();

    return Column(
      children: [
        AnswerButton(
          text: 'حقيقة ✓',
          isTrue: true,
          onPressed: () {
            vm.submitAnswer(true);
            // Play sound after answer
            if (vm.isCorrect != null) {
              if (vm.isCorrect!) {
                soundService.playCorrectSound();
              } else {
                soundService.playWrongSound();
              }
            }
          },
        ),
        const SizedBox(height: 12),
        AnswerButton(
          text: 'خرافة ✗',
          isTrue: false,
          onPressed: () {
            vm.submitAnswer(false);
            // Play sound after answer
            if (vm.isCorrect != null) {
              if (vm.isCorrect!) {
                soundService.playCorrectSound();
              } else {
                soundService.playWrongSound();
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildResultSection(BuildContext context, FreeQuestionsViewModel vm) {
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
        const SizedBox(height: 10),
        // Result Message
        Card(
          color: vm.isCorrect! ? AppColors.success : AppColors.error,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  vm.isCorrect!
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: AppColors.pureWhite,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vm.getResultMessage() ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Explanation Card
        Card(
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
                    // TASK 1: Share Button
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 15),
                      onPressed: () {
                        ShareUtils.shareResult(
                            questionText: vm.question!.question,
                            correctAnswer: vm.question!.correctAnswer,
                            explanation: vm.question!.explanation,
                            userAnswer: vm.userAnswer!);
                      },
                      tooltip: 'مشاركة',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Copy Button
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 15),
                      onPressed: () async {
                        await ShareUtils.copyQuestionContent(
                          questionText: vm.question!.question,
                          correctAnswer: vm.question!.correctAnswer,
                          explanation: vm.question!.explanation,
                        );
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
                      tooltip: 'نسخ',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Report Button
                    IconButton(
                      icon: const Icon(Icons.flag_rounded, size: 15),
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReportQuestionScreen(
                              questionId: vm.question!.id,
                              questionText: vm.question!.question,
                              category: vm.question!.category,
                              source: 'free',
                            ),
                          ),
                        );
                      },
                      tooltip: 'إبلاغ',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppColors.warning,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.warning.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Next Question Button
        ModernActionButton(
          icon: Icons.question_mark_rounded,
          label: 'سؤال جديد',
          color: AppColors.primaryDark,
          onTap: () => vm.nextQuestion(),
        )
      ],
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}
