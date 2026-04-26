import 'package:flutter/material.dart';
import '../data/models/leaderboard_model.dart';
import '../core/theme/app_colors.dart';

class LeaderboardItem extends StatelessWidget {
  final LeaderboardModel item;
  final bool isCurrentUser;

  const LeaderboardItem({
    super.key,
    required this.item,
    this.isCurrentUser = false,
  });

  Color _getRankColor() {
    switch (item.rank) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return Colors.transparent;
    }
  }

  String _getRankEmoji() {
    switch (item.rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();
    final hasSpecialRank = item.rank <= 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: hasSpecialRank
            ? Border.all(color: rankColor, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasSpecialRank)
              Text(
                _getRankEmoji(),
                style: const TextStyle(fontSize: 24),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${item.rank}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Text(
              item.userAvatar,
              style: const TextStyle(fontSize: 32),
            ),
          ],
        ),
        title: Text(
          item.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'صح: ${item.correctCount} | خطأ: ${item.wrongCount}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${item.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ),
      ),
    );
  }
}
