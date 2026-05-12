import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/sound_service.dart';
import '../../data/services/storage_service.dart';
import '../../viewmodels/challenge_viewmodel.dart';
import '../../widgets/answer_button.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/fake_live_counter.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/modern_action_button.dart';

class ChallengeQuestionScreen extends StatefulWidget {
  const ChallengeQuestionScreen({super.key});

  @override
  State<ChallengeQuestionScreen> createState() => _ChallengeQuestionScreenState();
}

class _ChallengeQuestionScreenState extends State<ChallengeQuestionScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'التحدي',
        showBack: true,
      ),
      body: SafeArea(
        child: Consumer<ChallengeViewModel>(
          builder: (context, vm, _) {
            if (vm.question == null) {
              return const Center(
                child: LoadingWidget(
                  message: 'جاري التحميل...',
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Challenge Header
                  _buildChallengeHeader(context), const SizedBox(height: 5),

                  // Question Card
                  _buildQuestionCard(context, vm), const SizedBox(height: 5),

                  // Answer Buttons or Result
                  if (!vm.hasAnswered)
                    _buildAnswerButtons(context, vm)
                  else
                    _buildResultSection(context, vm),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChallengeHeader(BuildContext context) {
    return Card(
      color: AppColors.primaryDark.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('⚔️', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وقت التحدي!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'جاوب وشارك مع أصدقائك 🔥',
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

  Widget _buildQuestionCard(BuildContext context, ChallengeViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category Chip
            Container(
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
                  const SizedBox(width: 4),
                  Text(
                    vm.question!.category,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Fake Live Counter
            FakeLiveCounter(
              totalPlayers: vm.fakePlayersCount,
              liveNow: vm.fakeLiveNowCount,
            ),
            const SizedBox(height: 10),

            // Question Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_rounded,
                color: AppColors.primaryDark,
                size: 25,
              ),
            ),
            const SizedBox(height: 10),

            // Question Text
            Text(
              vm.question!.question,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    height: 1.5,
                    fontSize: 20,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButtons(BuildContext context, ChallengeViewModel vm) {
    final soundService = getIt<SoundService>();

    return Column(
      children: [
        AnswerButton(
          text: 'حقيقة ✓',
          isTrue: true,
          onPressed: () async {
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
        const SizedBox(height: 15),
        AnswerButton(
          text: 'خرافة ✗',
          isTrue: false,
          onPressed: () async {
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

  Widget _buildResultSection(BuildContext context, ChallengeViewModel vm) {
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
        const SizedBox(height: 15),
        AnswerButton(
          text: 'خرافة ✗',
          isTrue: false,
          onPressed: () {},
          isSelected: vm.userAnswer == false,
          correctAnswer: vm.question!.correctAnswer,
        ),
        const SizedBox(height: 10),

        // Result Message with animation
        AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 500),
          child: AnimatedSlide(
            offset: Offset.zero,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: _buildResultMessage(context, vm),
          ),
        ),
        const SizedBox(height: 10),

        // Explanation Card
        AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 700),
          child: _buildExplanationCard(context, vm),
        ),
        const SizedBox(height: 10),

        // Action Buttons
        _buildActionButtons(context, vm),
      ],
    );
  }

  Widget _buildResultMessage(BuildContext context, ChallengeViewModel vm) {
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
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                vm.resultMessage ??
                    (isCorrect ? 'إجابة صحيحة! 🎉' : 'إجابة خاطئة 😅'),
                style: const TextStyle(
                  fontSize: 17,
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

  Widget _buildExplanationCard(BuildContext context, ChallengeViewModel vm) {
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
    );
  }

  Widget _buildActionButtons(BuildContext context, ChallengeViewModel vm) {
    return Column(
      children: [
        // Try Another Question Button
        _buildTryAnotherButton(context, vm), const SizedBox(height: 10),

        // Challenge Friend Button
        _buildShareChallengeButton(context, vm),
      ],
    );
  }

  Widget _buildTryAnotherButton(BuildContext context, ChallengeViewModel vm) {
    return ModernActionButton(
      icon: Icons.question_mark_rounded,
      label: 'جرّب سؤال آخر',
      color: AppColors.primaryDark,
      onTap: () => _loadAnotherQuestion(context, vm),
    );
  }

  Widget _buildShareChallengeButton(
      BuildContext context, ChallengeViewModel vm) {
    return ModernActionButton(
      icon: Icons.share,
      label: 'تحدي صديقك',
      color: AppColors.secondaryDark,
      onTap: () => _shareChallenge(context, vm),
    );
  }

  Future<void> _loadAnotherQuestion(
      BuildContext context, ChallengeViewModel vm) async {
    await vm.loadAnotherQuestion();

    if (context.mounted && vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error!),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareChallenge(
      BuildContext context, ChallengeViewModel vm) async {
    await vm.shareChallenge();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم مشاركة التحدي! 🔥'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
