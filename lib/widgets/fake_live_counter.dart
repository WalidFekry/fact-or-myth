import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class FakeLiveCounter extends StatefulWidget {
  final int totalPlayers;
  final int liveNow;

  const FakeLiveCounter({
    super.key,
    required this.totalPlayers,
    required this.liveNow,
  });

  @override
  State<FakeLiveCounter> createState() => _FakeLiveCounterState();
}

class _FakeLiveCounterState extends State<FakeLiveCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark.withOpacity(0.08),
            AppColors.secondaryDark.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryDark.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total players
          Expanded(
            child: _buildCounterItem(
              icon: '👥',
              count: _formatNumber(widget.totalPlayers),
              label: 'شخص جاوبوا على هذا التحدي',
              isDark: isDark,
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 24,
            color: isDark
                ? AppColors.dividerDark
                : AppColors.dividerLight,
          ),
          

          // Live now with pulse animation
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: child,
                );
              },
              child: _buildCounterItem(
                icon: '🔥',
                count: _formatNumber(widget.liveNow),
                label: 'شخص يلعبون الآن',
                isDark: isDark,
                isLive: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterItem({
    required String icon,
    required String count,
    required String label,
    required bool isDark,
    bool isLive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLive
                    ? AppColors.secondaryDark
                    : AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),

          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
