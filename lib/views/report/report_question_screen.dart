import 'package:fact_or_myth/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/report_model.dart';
import '../../data/services/storage_service.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../core/di/service_locator.dart';

class ReportQuestionScreen extends StatefulWidget {
  final int questionId;
  final String questionText;
  final String category;
  final String source; // 'daily' or 'free'

  const ReportQuestionScreen({
    super.key,
    required this.questionId,
    required this.questionText,
    required this.category,
    required this.source,
  });

  @override
  State<ReportQuestionScreen> createState() => _ReportQuestionScreenState();
}

class _ReportQuestionScreenState extends State<ReportQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _whatsappController = TextEditingController();
  
  String _selectedReason = AppConstants.reportReasons[0];

  @override
  void dispose() {
    _messageController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _submitReport(ReportViewModel vm) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final storageService = getIt<StorageService>();
    final userId = storageService.getUserId();

    final report = ReportModel(
      userId: userId,
      questionId: widget.questionId,
      questionText: widget.questionText,
      category: widget.category,
      source: widget.source,
      reason: _selectedReason,
      message: _messageController.text.trim(),
      whatsapp: _whatsappController.text.trim().isEmpty 
          ? null 
          : _whatsappController.text.trim(),
    );

    final success = await vm.submitReport(report);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.successMessage ?? 'تم إرسال البلاغ بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Wait a bit then pop
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ChangeNotifierProvider(
      create: (_) => getIt<ReportViewModel>(),
      child: Scaffold(
        appBar: const CustomAppBar(title: "الإبلاغ عن مشكلة",showBack: true,),
        body: Consumer<ReportViewModel>(
          builder: (context, vm, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Icon
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          size: 30,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      'ساعدنا في تحسين المحتوى',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إذا وجدت خطأ في السؤال أو الإجابة، يرجى إخبارنا',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    // Question Preview Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.quiz_rounded,
                                size: 18,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'السؤال المبلغ عنه',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.questionText,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildInfoChip(widget.category, Icons.category_rounded),
                              _buildInfoChip(
                                widget.source == 'daily' ? 'سؤال يومي' : 'أسئلة حرة',
                                Icons.source_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Reason Dropdown
                    Text(
                      'نوع المشكلة',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedReason,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      items: AppConstants.reportReasons.map((reason) {
                        return DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedReason = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    // Message TextArea
                    Text(
                      'تفاصيل المشكلة',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'اكتب تفاصيل المشكلة هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى كتابة تفاصيل المشكلة';
                        }
                        if (value.trim().length < 10) {
                          return 'يرجى كتابة تفاصيل أكثر (10 أحرف على الأقل)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // WhatsApp (Optional)
                    Text(
                      'رقم الواتساب (اختياري)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'مثال: 01234567890',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone_rounded,
                          color: AppColors.whatsapp,
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (value.trim().length < 10) {
                            return 'رقم الواتساب غير صحيح';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سنتواصل معك عبر الواتساب إذا احتجنا توضيح',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 15),
                    // Error Message
                    if (vm.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                vm.error!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : () => _submitReport(vm),
                        child: vm.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.pureWhite,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'إرسال البلاغ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Info Note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.info,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'سيتم مراجعة البلاغ من قبل فريقنا وتصحيح المحتوى في أقرب وقت',
                              style: TextStyle(
                                color: AppColors.info,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
