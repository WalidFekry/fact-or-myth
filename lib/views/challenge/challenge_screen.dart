import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/ad_service.dart';
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
                    const Spacer(),
                    // Refresh Button
                    _buildRefreshButton(context, vm),
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
  
  Widget _buildRefreshButton(BuildContext context, ChallengeViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: vm.isSyncing ? null : () => _showRefreshDialog(context, vm),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withOpacity(0.5)
                : AppColors.surfaceLight.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryDark.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: vm.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                  ),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
        ),
      ),
    );
  }
  
  Future<void> _showRefreshDialog(BuildContext context, ChallengeViewModel vm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Text('🔄', style: TextStyle(fontSize: 15)),
            SizedBox(width: 8),
            Text('تحديث الأسئلة'),
          ],
        ),
        content: const Text(
          'سيتم تحميل أحدث الأسئلة وحفظها على جهازك. قد يستغرق ذلك بضع ثوانٍ.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await _performRefresh(context, vm);
    }
  }
  
  Future<void> _performRefresh(BuildContext context, ChallengeViewModel vm) async {
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري تحديث الأسئلة...',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Perform sync
    final success = await vm.syncQuestions();

    // Close loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Show result
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.pureWhite),
                SizedBox(width: 8),
                Expanded(child: Text('تم تحديث الأسئلة بنجاح')),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppColors.pureWhite),
                SizedBox(width: 8),
                Expanded(child: Text('حدث خطأ أثناء تحديث الأسئلة')),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
    // Show interstitial ad before starting challenge
    final adService = getIt<AdService>();
    adService.showInterstitialAd();
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
