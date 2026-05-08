import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
class AdvancedStreakCard extends StatefulWidget {
  final int streak;

  const AdvancedStreakCard({
    super.key,
    required this.streak,
  });

  @override
  State<AdvancedStreakCard> createState() => _AdvancedStreakCardState();
}

class _AdvancedStreakCardState extends State<AdvancedStreakCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Only animate for legendary level
    if (_getStreakLevel() == StreakLevel.legendary) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 3000),
        vsync: this,
      )..repeat(reverse: true);

      _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (_getStreakLevel() == StreakLevel.legendary) {
      _controller.dispose();
    }
    super.dispose();
  }

  StreakLevel _getStreakLevel() {
    if (widget.streak >= 30) return StreakLevel.legendary;
    if (widget.streak >= 15) return StreakLevel.advanced;
    if (widget.streak >= 7) return StreakLevel.active;
    return StreakLevel.beginner;
  }

  @override
  Widget build(BuildContext context) {
    final level = _getStreakLevel();
    
    // Legendary level with subtle animation
    if (level == StreakLevel.legendary) {
      return AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) => _buildCompactCard(context, level, _glowAnimation.value),
      );
    }
    
    // Other levels without animation
    return _buildCompactCard(context, level, 0.3);
  }

  Widget _buildCompactCard(BuildContext context, StreakLevel level, double glowIntensity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: level != StreakLevel.beginner
              ? LinearGradient(
                  colors: level.gradientColors
                      .map((c) => c.withOpacity(isDark ? 0.06 : 0.04))
                      .toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: level == StreakLevel.legendary
              ? Border.all(
                  color: level.primaryColor.withOpacity(glowIntensity * 0.6),
                  width: 1,
                )
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          // Icon with level-specific styling
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: level != StreakLevel.beginner
                  ? LinearGradient(
                      colors: level.gradientColors
                          .map((c) => c.withOpacity(0.2))
                          .toList(),
                    )
                  : null,
              color: level == StreakLevel.beginner
                  ? AppColors.warning.withOpacity(0.1)
                  : null,
              borderRadius: BorderRadius.circular(10),
              border: level != StreakLevel.beginner
                  ? Border.all(
                      color: level.primaryColor.withOpacity(0.3),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                level.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          // Title and subtitle
          title: Row(
            children: [
              Text(
               'سلسلة الأيام',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: level.primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              // Compact badge for non-beginner
              if (level != StreakLevel.beginner)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: level.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: level.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    level.badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: level.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              level.motivationalText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
            ),
          ),
          // Trailing: Streak count with mini progress
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.streak}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: level.primaryColor,
                  shadows: level == StreakLevel.legendary
                      ? [
                          Shadow(
                            color: level.primaryColor.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              ),
              // Mini progress indicator
              if (level != StreakLevel.legendary)
                Container(
                  width: 40,
                  height: 3,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: level.primaryColor.withOpacity(0.2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: _getProgress(level),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: level.primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _getProgress(StreakLevel level) {
    final nextMilestone = level == StreakLevel.beginner
        ? 7
        : level == StreakLevel.active
            ? 15
            : 30;
    return (widget.streak % nextMilestone) / nextMilestone;
  }
}

enum StreakLevel {
  beginner,
  active,
  advanced,
  legendary;

  String get emoji {
    switch (this) {
      case StreakLevel.beginner:
        return '🔥';
      case StreakLevel.active:
        return '🧠';
      case StreakLevel.advanced:
        return '⚡';
      case StreakLevel.legendary:
        return '👑';
    }
  }

  String get badgeText {
    switch (this) {
      case StreakLevel.beginner:
        return '';
      case StreakLevel.active:
        return 'نشيط';
      case StreakLevel.advanced:
        return 'محترف';
      case StreakLevel.legendary:
        return 'أسطورة';
    }
  }

  String get motivationalText {
    switch (this) {
      case StreakLevel.beginner:
        return 'استمر في التقدم';
      case StreakLevel.active:
        return 'أداء رائع! استمر';
      case StreakLevel.advanced:
        return 'أداء ممتاز! أنت محترف';
      case StreakLevel.legendary:
        return 'أنت أسطورة! ملك الحقيقة';
    }
  }

  Color get primaryColor {
    switch (this) {
      case StreakLevel.beginner:
        return AppColors.warning;
      case StreakLevel.active:
        return AppColors.info;
      case StreakLevel.advanced:
        return AppColors.secondaryDark;
      case StreakLevel.legendary:
        return AppColors.gold;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case StreakLevel.beginner:
        return [AppColors.warning, AppColors.warning];
      case StreakLevel.active:
        return [AppColors.info, AppColors.primaryDark];
      case StreakLevel.advanced:
        return [AppColors.secondaryDark, AppColors.primaryDark];
      case StreakLevel.legendary:
        return [AppColors.gold, AppColors.warning];
    }
  }
}
