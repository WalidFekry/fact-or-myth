import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/assets.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'avatar_selector.dart';

class RegisterDialog extends StatefulWidget {
  final VoidCallback? onRegistered;

  const RegisterDialog({super.key, this.onRegistered});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _nameController = TextEditingController();
  String _selectedAvatar = AppConstants.avatars[0];
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'من فضلك أدخل اسمك';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.register(
      _nameController.text.trim(),
      _selectedAvatar,
    );

    if (success && mounted) {
      widget.onRegistered?.call();
      Navigator.pop(context, true);
    } else if (mounted && authVM.error != null) {
      setState(() {
        _errorMessage = authVM.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          color: AppColors.primaryDark,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'إنشاء حساب',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name Input
                  Text(
                    'الاسم',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'أدخل اسمك',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      errorText: _errorMessage,
                      errorStyle: const TextStyle(fontSize: 12),
                    ),
                    textAlign: TextAlign.right,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Avatar Selection
                  Text(
                    'اختر صورتك',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  AvatarSelector(
                    selectedAvatar: _selectedAvatar,
                    onAvatarSelected: (avatar) {
                      setState(() {
                        _selectedAvatar = avatar;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authVM.isLoading ? null : _register,
                      child: authVM.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('ابدأ المنافسة'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper function to show the dialog
Future<bool?> showRegisterDialog(BuildContext context, {VoidCallback? onRegistered}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => RegisterDialog(onRegistered: onRegistered),
  );
}
