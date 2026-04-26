import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../home/home_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _enableNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = getIt<NotificationService>();
      final storageService = getIt<StorageService>();
      
      // Request permission
      final granted = await notificationService.requestPermission();
      
      if (granted) {
        // Subscribe to topics
        await notificationService.subscribeToTopics();
        
        // Save FCM token to backend if user is logged in
        await notificationService.saveFCMTokenToBackend();
        
        // Mark as notification permission shown
        await storageService.setNotificationPermissionShown(true);
        await storageService.setNotificationsEnabled(true);
        
        if (mounted) {
          // Navigate to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        // Permission denied
        await storageService.setNotificationPermissionShown(true);
        await storageService.setNotificationsEnabled(false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم منح إذن الإشعارات'),
              backgroundColor: AppColors.warning,
            ),
          );
          
          // Still navigate to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _skipNotifications() async {
    final storageService = getIt<StorageService>();
    
    // Mark as shown but not enabled
    await storageService.setNotificationPermissionShown(true);
    await storageService.setNotificationsEnabled(false);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 60,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'فعّل الإشعارات 🔔',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'وصلك أسئلة يومية، اقتباسات، ومحتوى مميز أول بأول',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Benefits
              _buildBenefit(
                icon: Icons.quiz_rounded,
                text: 'تذكير بالسؤال اليومي',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                icon: Icons.lightbulb_rounded,
                text: 'اقتباسات ومعلومات مفيدة',
              ),
              const SizedBox(height: 12),
              _buildBenefit(
                icon: Icons.star_rounded,
                text: 'تحديثات التطبيق والمميزات الجديدة',
              ),
              
              const Spacer(),
              
              // Enable Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enableNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureWhite),
                          ),
                        )
                      : const Text(
                          'تفعيل الإشعارات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.pureWhite,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Skip Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: _isLoading ? null : _skipNotifications,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ليس الآن',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.success,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
