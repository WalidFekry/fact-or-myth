import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/time_utils.dart';
import '../../viewmodels/comment_viewmodel.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_app_bar.dart';

class CommentsScreen extends StatefulWidget {
  final int questionId;

  const CommentsScreen({super.key, required this.questionId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment(CommentViewModel vm) async {
    final text = _commentController.text.trim();

    // Validate empty
    if (text.isEmpty) {
      vm.setError('يرجى كتابة تعليق');
      return;
    }

    // Validate links
    if (containsLink(text)) {
      vm.setError('غير مسموح بإضافة روابط');
      return;
    }

    final success = await vm.addComment(
      widget.questionId,
      text,
    );

    if (success) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<CommentViewModel>()..loadComments(widget.questionId),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'التعليقات',
          showBack: true,
        ),
        body: Consumer<CommentViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                // Comments List
                Expanded(
                  child: vm.isLoading && vm.comments.isEmpty
                      ? const LoadingWidget()
                      : vm.error != null && vm.comments.isEmpty
                          ? ErrorDisplayWidget(
                              message: vm.error!,
                              onRetry: () => vm.loadComments(widget.questionId),
                            )
                          : vm.comments.isEmpty
                              ? Center(
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
                                        child: Icon(
                                          Icons.comment_rounded,
                                          size: 40,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'لا توجد تعليقات بعد',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: vm.comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = vm.comments[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Avatar
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryDark.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                comment.userAvatar,
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        comment.userName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '•',
                                                      style: Theme.of(context).textTheme.bodySmall,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      comment.createdAt.toString(),
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            fontSize: 12,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  comment.comment,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        fontSize: 14,
                                                        height: 1.4,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                ),

                // Comment Input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.overlayLight,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick Reaction Chips
                        if (!vm.hasUserCommented())
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildQuickReactionChip('❤️ إعجاب', vm),
                                _buildQuickReactionChip('🔥 اتفق', vm),
                                _buildQuickReactionChip('😂 ضحكني', vm),
                                _buildQuickReactionChip('🤔 مثير للتفكير', vm),
                              ],
                            ),
                          ),
                        // Already commented message
                        if (vm.hasUserCommented())
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'لقد قمت بإضافة تعليق بالفعل على هذا السؤال',
                                    style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Error message
                        if (vm.error != null && vm.comments.isNotEmpty && !vm.hasUserCommented())
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    vm.error!,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Input row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                enabled: !vm.hasUserCommented(),
                                decoration: InputDecoration(
                                  hintText: vm.hasUserCommented() 
                                      ? 'تم إضافة تعليقك' 
                                      : 'اكتب تعليقك...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                textAlign: TextAlign.right,
                                maxLines: null,
                                onChanged: (_) {
                                  // Clear error when user types
                                  if (vm.error != null) {
                                    vm.clearError();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: vm.hasUserCommented() 
                                    ? AppColors.primaryDark.withOpacity(0.3)
                                    : AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: (vm.isLoading || vm.hasUserCommented()) 
                                    ? null 
                                    : () => _addComment(vm),
                                icon: const Icon(Icons.send_rounded, size: 20),
                                color: AppColors.pureWhite,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickReactionChip(String text, CommentViewModel vm) {
    return InkWell(
      onTap: vm.isLoading ? null : () {
        _commentController.text = text;
        _addComment(vm);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryDark.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}
