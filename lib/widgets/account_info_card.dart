import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
class AccountInfoCard extends StatelessWidget {
  final String createdAt;

  const AccountInfoCard({
    super.key,
    required this.createdAt,
  });

  /// Calculate days since account creation
  int _getDaysSinceCreation() {
    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      return now.difference(createdDate).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Get compact membership duration in Arabic
  String _getCompactMembershipDuration() {
    final days = _getDaysSinceCreation();

    if (days == 0) {
      return 'انضممت اليوم';
    } else if (days == 1) {
      return 'أنت معنا منذ يوم';
    } else if (days < 7) {
      return 'أنت معنا منذ $days أيام';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return weeks == 1
          ? 'أنت معنا منذ أسبوع'
          : 'أنت معنا منذ $weeks أسابيع';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return months == 1
          ? 'أنت معنا منذ شهر'
          : 'أنت معنا منذ $months أشهر';
    } else {
      final years = (days / 365).floor();
      return years == 1
          ? 'أنت معنا منذ سنة'
          : 'أنت معنا منذ $years سنوات';
    }
  }

  /// Format creation date in compact format
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
    final membershipText = _getCompactMembershipDuration();
    final formattedDate = _getFormattedDate();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isNew
              ? LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(isDark ? 0.06 : 0.04),
                    AppColors.success.withOpacity(isDark ? 0.04 : 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          // Icon
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isNew ? AppColors.success : AppColors.primaryDark)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isNew ? Icons.celebration_rounded : Icons.calendar_today_rounded,
              color: isNew ? AppColors.success : AppColors.primaryDark,
              size: 20,
            ),
          ),
          // Title and subtitle
          title: Text(
          membershipText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              isNew ? 'شكراً لانضمامك معنا' : 'عضو في المجتمع',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isNew ? AppColors.success : null,
                  ),
            ),
          ),
          // Trailing: Compact date badge
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isNew ? AppColors.success : AppColors.primaryDark)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isNew ? AppColors.success : AppColors.primaryDark)
                    .withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isNew ? AppColors.success : AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
