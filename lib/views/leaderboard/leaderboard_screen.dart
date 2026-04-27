import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/leaderboard_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../data/models/leaderboard_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_app_bar.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<LeaderboardViewModel>(),
      builder: (context, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'لائحة المتصدرين',
            showBack: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 22),
                onPressed: () {
                  final authVM = context.read<AuthViewModel>();
                  final userId = authVM.getUserId();
                  context.read<LeaderboardViewModel>().loadLeaderboard(userId: userId);
                },
              ),
            ],
          ),
          body: Consumer2<LeaderboardViewModel, AuthViewModel>(
            builder: (context, leaderboardVM, authVM, _) {
              // Load leaderboard on first build only
              if (!leaderboardVM.hasLoadedOnce && !leaderboardVM.isLoading) {
                Future.microtask(() {
                  final userId = authVM.getUserId();
                  leaderboardVM.loadLeaderboard(userId: userId);
                });
              }

            if (leaderboardVM.isLoading) {
              return const LoadingWidget(message: 'جاري التحميل...');
            }

            if (leaderboardVM.error != null) {
              return ErrorDisplayWidget(
                message: leaderboardVM.error!,
                onRetry: () {
                  final userId = authVM.getUserId();
                  leaderboardVM.loadLeaderboard(userId: userId);
                },
              );
            }

            if (leaderboardVM.leaderboard.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_people_rounded,
                        size: 40,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد منافسين حالياً 😅',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'كن أول من يشارك في الترتيب',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            final currentUserId = authVM.getUserId();
            
            // Show message if user is not logged in
            if (currentUserId == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.login_rounded,
                        size: 40,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'سجل دخول لترى ترتيبك',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              );
            }
            
            final myRank = leaderboardVM.myRank;
            final top3 = leaderboardVM.leaderboard.take(3).toList();
            
            // Filter out current user from rest if they're in top 3
            final rest = leaderboardVM.leaderboard.skip(3).where((item) {
              return item.userId != currentUserId;
            }).toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Current User Card (ALWAYS at top if user is logged in)
                  if (myRank != null) ...[
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryDark.withOpacity(0.15),
                            AppColors.primaryDark.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryDark.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: _buildCurrentUserCard(context, myRank),
                    ),
                    
                    // Status message based on eligibility
                    if (myRank.answersCount == 0)
                      _buildStatusMessage(
                        context,
                        Icons.play_circle_outline_rounded,
                        'ابدأ بالإجابة على الأسئلة لتظهر في الترتيب',
                        AppColors.primaryDark,
                      )
                    else if (!myRank.isEligible)
                      _buildStatusMessage(
                        context,
                        Icons.local_fire_department_rounded,
                        'أجب على ${5 - myRank.answersCount} أسئلة أخرى لتدخل المنافسة 🔥',
                        AppColors.warning,
                      ),
                  ],
                  
                  // Top 3 Podium
                  if (top3.isNotEmpty)
                    _buildPodium(context, top3, currentUserId),

                  // Rest of Leaderboard
                  if (rest.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      child: Column(
                        children: rest.map((item) {
                          return _buildLeaderboardItem(context, item, false);
                        }).toList(),
                      ),
                    ),
                  ] else if (top3.isEmpty) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'لا يوجد منافسين حالياً',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ),
            );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusMessage(
    BuildContext context,
    IconData icon,
    String message,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCard(BuildContext context, LeaderboardModel user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryDark,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.userAvatar,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.userName,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.rank != null ? '#${user.rank}' : '--',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ترتيبك الحالي',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryDark,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.check_circle_rounded,
                  'صح',
                  '${user.correctCount}',
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.cancel_rounded,
                  'خطأ',
                  '${user.wrongCount}',
                  AppColors.error,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.percent_rounded,
                  'النسبة',
                  '${user.percentage.toStringAsFixed(1)}%',
                  AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<LeaderboardModel> top3, int? currentUserId) {
    // Arrange: 2nd, 1st, 3rd
    final first = top3.length > 0 ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd Place
          if (second != null)
            Expanded(
              child: _buildPodiumItem(
                context,
                second,
                AppColors.silver,
                '🥈',
                80,
                currentUserId == second.userId,
              ),
            ),
          const SizedBox(width: 8),
          // 1st Place
          if (first != null)
            Expanded(
              child: _buildPodiumItem(
                context,
                first,
                AppColors.gold,
                '🥇',
                100,
                currentUserId == first.userId,
              ),
            ),
          const SizedBox(width: 8),
          // 3rd Place
          if (third != null)
            Expanded(
              child: _buildPodiumItem(
                context,
                third,
                AppColors.bronze,
                '🥉',
                60,
                currentUserId == third.userId,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    LeaderboardModel item,
    Color color,
    String emoji,
    double height,
    bool isCurrentUser,
  ) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentUser ? AppColors.primaryDark : color,
              width: isCurrentUser ? 2.5 : 2,
            ),
          ),
          child: Center(
            child: Text(
              item.userAvatar,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Name
        Text(
          item.userName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        // Percentage
        Text(
          '${item.percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    LeaderboardModel item,
    bool isCurrentUser,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryDark.withOpacity(0.1)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${item.rank}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Avatar
            Text(
              item.userAvatar,
              style: const TextStyle(fontSize: 28),
            ),
          ],
        ),
        title: Text(
          item.userName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'صح: ${item.correctCount} | خطأ: ${item.wrongCount}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${item.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
