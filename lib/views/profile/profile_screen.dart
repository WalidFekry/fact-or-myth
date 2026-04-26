import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/assets.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../data/services/api_service.dart';
import '../../data/services/sound_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_app_bar.dart';
import '../onboarding/onboarding_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<ProfileViewModel>()..loadProfile()),
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'الملف الشخصي',
          showBack: false,
          actions: [
            // TASK 6: Sound Toggle in AppBar (LEFT side)
            Consumer<ProfileViewModel>(
              builder: (context, vm, _) {
                if (vm.profile == null) return const SizedBox.shrink();
                final soundService = getIt<SoundService>();
                return IconButton(
                  icon: Icon(
                    soundService.isSoundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    size: 22,
                  ),
                  onPressed: () {
                    soundService.toggleSound();
                    setState(() {}); // Refresh icon
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          soundService.isSoundEnabled
                              ? 'تم تفعيل الصوت 🔊'
                              : 'تم إيقاف الصوت 🔇',
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.primaryDark,
                      ),
                    );
                  },
                  tooltip: soundService.isSoundEnabled ? 'إيقاف الصوت' : 'تفعيل الصوت',
                );
              },
            ),
          ],
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const LoadingWidget(message: 'جاري التحميل...');
            }

            if (vm.error != null) {
              return ErrorDisplayWidget(
                message: vm.error!,
                onRetry: vm.loadProfile,
              );
            }

            if (vm.profile == null) {
              return Center(
                child: Text(
                  'لا توجد بيانات',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            final profile = vm.profile!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                children: [
                  // Header Section: Avatar, Name, Edit Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
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
                            profile.avatar,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(profile: profile),
                                ),
                              ).then((_) {
                                final vm = context.read<ProfileViewModel>();
                                vm.loadProfile();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'تعديل الملف',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Grid (2x2)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.quiz_rounded,
                          label: 'إجمالي',
                          value: '${profile.totalAnswers}',
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.check_circle_rounded,
                          label: 'صحيحة',
                          value: '${profile.correctAnswers}',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.cancel_rounded,
                          label: 'خاطئة',
                          value: '${profile.wrongAnswers}',
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.percent_rounded,
                          label: 'الدقة',
                          value: '${profile.accuracy.toStringAsFixed(1)}%',
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Streak Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '🔥',
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
                                  'سلسلة الأيام',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${profile.currentStreak} يوم متتالي',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${profile.currentStreak}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TASK 8: Notifications Settings Card
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'الإشعارات',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      subtitle: Text(
                        'تلقي إشعارات الأسئلة اليومية',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: _buildNotificationToggle(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Account Actions Section
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          enabled: !_isDeleting,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(_isDeleting ? 0.05 : 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _isDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.delete_forever_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                          ),
                          title: Text(
                            'حذف الحساب',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _isDeleting ? AppColors.error.withOpacity(0.5) : AppColors.error,
                                ),
                          ),
                          subtitle: Text(
                            _isDeleting ? 'جاري الحذف...' : 'حذف نهائي لجميع بياناتك',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: _isDeleting ? AppColors.textSecondaryDark.withOpacity(0.5) : AppColors.textSecondaryDark,
                          ),
                          onTap: _isDeleting ? null : () => _showDeleteAccountDialog(context),
                        ),
                        const Divider(height: 1, indent: 72, endIndent: 16),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.warning,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'تسجيل الخروج',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          subtitle: Text(
                            'الخروج من الحساب الحالي',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.textSecondaryDark,
                          ),
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Branding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          AppAssets.logo,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.quiz_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'حقيقة ولا خرافة؟',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }


  void _showDeleteAccountDialog(BuildContext context) {
    // Prevent showing dialog if already deleting
    if (_isDeleting) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppColors.error,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('تحذير'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد حذف الحساب نهائيًا؟\n\n'
          'سيتم حذف:\n'
          '• جميع إجاباتك\n'
          '• جميع تعليقاتك\n'
          '• ترتيبك في المنافسة\n'
          '• بيانات حسابك\n\n'
          'هذا الإجراء لا يمكن التراجع عنه!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف الحساب'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    // Prevent double-click
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    final authVM = context.read<AuthViewModel>();
    final userId = authVM.getUserId();
    
    if (userId == null) {
      setState(() {
        _isDeleting = false;
      });
      return;
    }
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
    
    try {
      final apiService = getIt<ApiService>();
      await apiService.deleteAccount(userId);
      
      // SUCCESS: Close loading dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // TASK 1: Clear ALL local data (including cache)
      await authVM.deleteAccountData();
      
      // TASK 3: Navigate to onboarding (remove all routes)
      if (mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
        
        // Show success message after navigation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الحساب بنجاح'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // ERROR: Close loading dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Reset deleting state
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.warning,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('تسجيل الخروج'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authVM = context.read<AuthViewModel>();
    
    // TASK 1: Clear all session data
    await authVM.logout();
    
    if (context.mounted) {
      // TASK 3: Navigate to onboarding with complete reset
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الخروج بنجاح'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // TASK 8: Build notification toggle
  Widget _buildNotificationToggle() {
    final storageService = getIt<StorageService>();
    final notificationService = getIt<NotificationService>();
    final isEnabled = storageService.areNotificationsEnabled();

    return Switch(
      value: isEnabled,
      onChanged: (value) async {
        await notificationService.toggleNotifications(value);
        setState(() {}); // Refresh UI
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? 'تم تفعيل الإشعارات 🔔'
                    : 'تم إيقاف الإشعارات',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: value ? AppColors.success : AppColors.textSecondaryDark,
            ),
          );
        }
      },
      activeColor: AppColors.primaryDark,
    );
  }

}
