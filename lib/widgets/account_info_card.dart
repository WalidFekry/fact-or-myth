import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
class AccountInfoCard extends StatelessWidget {
  final String createdAt;

  const AccountInfoCard({
    super.key,
    required this.createdAt,
  });

  int _getDaysSinceCreation() {
    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      return now.difference(createdDate).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Get relative membership duration in Arabic
  String _getMembershipDuration() {
    final days = _getDaysSinceCreation();
    return days == 0 ? 'انضم حديثًا' : 'عضو منذ $days أيام';
  }

  /// Format creation date in Arabic-friendly format
  String _getFormattedDate() {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  /// Check if user is new (less than 7 days)
  bool _isNewUser() {
    return _getDaysSinceCreation() < 7;
  }

  @override
  Widget build(BuildContext context) {
    final isNew = _isNewUser();
    final membershipText = _getMembershipDuration();
    final formattedDate = _getFormattedDate();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              (isNew ? AppColors.success : AppColors.primaryDark)
                  .withOpacity(isDark ? 0.1 : 0.05),
              (isNew ? AppColors.success : AppColors.secondaryDark)
                  .withOpacity(isDark ? 0.08 : 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isNew ? AppColors.success : AppColors.primaryDark)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isNew ? AppColors.success : AppColors.primaryDark)
                      .withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                isNew ? Icons.celebration_rounded : Icons.calendar_today_rounded,
                color: isNew ? AppColors.success : AppColors.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          membershipText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (formattedDate.isNotEmpty)
                    Text(
                      'تم إنشاء الحساب في $formattedDate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                    ),
                  if (isNew) ...[
                    const SizedBox(height: 4),
                    Text(
                      'شكراً لانضمامك معنا',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
