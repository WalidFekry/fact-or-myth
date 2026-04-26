import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/avatar_selector.dart';
import '../../widgets/custom_app_bar.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegistered;

  const RegisterScreen({super.key, this.onRegistered});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  String _selectedAvatar = AppConstants.avatars[0];
  String? _errorMessage;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateInput);
    _nameController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isValid = _nameController.text.trim().isNotEmpty;
      if (_isValid) {
        _errorMessage = null;
      }
    });
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'من فضلك أدخل اسمك';
      });
      return;
    }

    // Validate name length (max 15 characters)
    if (name.length > 15) {
      setState(() {
        _errorMessage = 'الاسم طويل جداً (الحد الأقصى 15 حرف)';
      });
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.register(
      name,
      _selectedAvatar,
    );

    if (success && mounted) {
      widget.onRegistered?.call();
      Navigator.pop(context);
    } else if (mounted && authVM.error != null) {
      setState(() {
        _errorMessage = authVM.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'تسجيل حساب جديد',
        showBack: true,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Message
                Text(
                  'مرحباً بك!',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'أنشئ حسابك للمشاركة في الترتيب',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Name Input
                Text(
                  'الاسم',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  maxLength: 15,
                  decoration: InputDecoration(
                    hintText: 'أدخل اسمك',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primaryDark,
                      size: 20,
                    ),
                    counterText: '${_nameController.text.length}/15',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryDark,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.error,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  textAlign: TextAlign.right,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Avatar Selection
                Text(
                  'اختر صورتك',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (authVM.isLoading || !_isValid) ? null : _register,
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
          );
        },
      ),
    );
  }
}
