import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/challenge_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/modern_action_button.dart';
import 'challenge_question_screen.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ChallengeViewModel>(),
      child: const Scaffold(
        appBar: CustomAppBar(
          title: 'تحدي صديق',
          actions: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("⚔️",style: TextStyle(fontSize: 18),),
            )
          ],
          showBack: false,),
        body: _ChallengeScreenBody(),
      ),
    );
  }
}

class _ChallengeScreenBody extends StatelessWidget {
  const _ChallengeScreenBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            _buildHeroSection(context),
            const SizedBox(height: 5),
            
            // Category Selector
            _buildCategorySelector(context),
            const SizedBox(height: 5),
            
            // Start Challenge Button
            _buildStartButton(context),
            const SizedBox(height: 5),
            
            // How it Works Section
            _buildHowItWorksSection(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark.withOpacity(0.1),
              AppColors.secondaryDark.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🧠', style: TextStyle(fontSize: 25)),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'تحدى أصدقائك!',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              'اختر سؤال وشارك التحدي مع أصدقائك\nوشوف مين فيكم الأذكى! 🔥',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Consumer<ChallengeViewModel>(
      builder: (context, vm, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'اختر الفئة',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryDark.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: vm.selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      borderRadius: BorderRadius.circular(12),
                      items: AppConstants.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          vm.setCategory(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Consumer<ChallengeViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const LoadingWidget();
        }
        if (vm.error != null) {
          return ErrorDisplayWidget(
            message: vm.error!,
            onRetry: () => vm.clearError(),
          );
        }
        return ModernActionButton(
          icon: Icons.flash_on,
          label: 'ابدأ التحدي',
          color: AppColors.primaryDark,
          onTap: () => _startChallenge(context, vm),
        );
      },
    );
  }

  Future<void> _startChallenge(
      BuildContext context, ChallengeViewModel vm) async {
    await vm.loadChallengeQuestion();

    if (vm.question != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: vm,
            child: const ChallengeQuestionScreen(),
          ),
        ),
      );
    }
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'كيف يعمل التحدي؟',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildStep(context, '1', 'اختر الفئة المناسبة'),
            const SizedBox(height: 10),
            _buildStep(context, '2', 'اضغط على "ابدأ التحدي"'),
            const SizedBox(height: 10),
            _buildStep(context, '3', 'جاوب على السؤال'),
            const SizedBox(height: 10),
            _buildStep(context, '4', 'شارك التحدي مع أصدقائك'),
            const SizedBox(height: 10),
            _buildStep(context, '5', 'شوف مين فيكم جاوب صح! 🏆'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryDark.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
