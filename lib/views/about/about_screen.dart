import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/assets.dart';
import '../../widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الإعدادات والمعلومات',
        showBack: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // About App Section
            _buildAboutSection(context),
            
            const SizedBox(height: 8),
            
            // Social Links Section
            _buildSectionHeader(context, 'تواصل معنا'),
            _buildSocialLinks(context),
            
            const SizedBox(height: 8),
            
            // Contact & Suggestions Section
            _buildSectionHeader(context, 'الدعم والاقتراحات'),
            _buildContactSection(context),
            
            const SizedBox(height: 8),
            
            // More Apps Section
            _buildSectionHeader(context, 'تطبيقات أخرى'),
            _buildMoreAppsSection(context),
            
            const SizedBox(height: 8),
            
            // Privacy Policy
            _buildSectionHeader(context, 'الخصوصية'),
            _buildPrivacySection(context),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              AppAssets.logo,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    size: 40,
                    color: AppColors.pureWhite,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // App Name
          Text(
            'حقيقة ولا خرافة؟',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            'اختبر معلوماتك اليومية بطريقة ممتعة وسريعة',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryDark,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'الإصدار 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryDark,
              ),
        ),
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            icon: Icons.facebook_rounded,
            iconColor: AppColors.facebook,
            title: 'صفحة الفيسبوك',
            subtitle: 'تابعنا على فيسبوك',
            onTap: () => _launchURL('https://facebook.com'),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            icon: Icons.code_rounded,
            iconColor: AppColors.textPrimaryDark,
            title: 'الكود المصدري',
            subtitle: 'شاهد المشروع على GitHub',
            onTap: () => _launchURL('https://github.com'),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            icon: Icons.star_rounded,
            iconColor: AppColors.warning,
            title: 'قيم التطبيق',
            subtitle: 'ساعدنا بتقييمك على المتجر',
            onTap: () => _launchURL('https://play.google.com/store'),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            icon: Icons.share_rounded,
            iconColor: AppColors.info,
            title: 'شارك التطبيق',
            subtitle: 'شارك مع أصدقائك',
            onTap: () => _shareApp(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            icon: Icons.chat_rounded,
            iconColor: AppColors.whatsapp,
            title: 'تواصل عبر واتساب',
            subtitle: 'راسلنا مباشرة',
            onTap: () => _launchWhatsApp('مرحبًا، أريد التواصل بخصوص التطبيق'),
          ),
          _buildDivider(),
          _buildListTile(
            context,
            icon: Icons.lightbulb_outline_rounded,
            iconColor: AppColors.warning,
            title: 'إرسال اقتراح',
            subtitle: 'شاركنا أفكارك',
            onTap: () => _showSuggestionDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreAppsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            icon: Icons.apps_rounded,
            iconColor: AppColors.primaryDark,
            title: 'تطبيقات أخرى',
            subtitle: 'اكتشف المزيد من تطبيقاتنا',
            onTap: () => _launchURL('https://play.google.com/store'),
          ),
          _buildListTile(
            context,
            icon: Icons.apps_rounded,
            iconColor: AppColors.primaryDark,
            title: 'تطبيقات أخرى',
            subtitle: 'اكتشف المزيد من تطبيقاتنا',
            onTap: () => _launchURL('https://play.google.com/store'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            icon: Icons.privacy_tip_outlined,
            iconColor: AppColors.info,
            title: 'سياسة الخصوصية',
            subtitle: 'اطلع على سياسة الخصوصية',
            onTap: () => _launchURL('https://example.com/privacy'),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.textSecondaryDark,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
    );
  }

  // URL Launcher Methods
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWhatsApp(String message) async {
    final phoneNumber = '1234567890'; // Replace with actual number
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    await _launchURL(url);
  }

  void _shareApp() {
    Share.share(
      'جرب تطبيق حقيقة ولا خرافة؟ - اختبر معلوماتك اليومية!\n'
      'https://play.google.com/store',
      subject: 'حقيقة ولا خرافة؟',
    );
  }

  void _showSuggestionDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('إرسال اقتراح'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'اكتب اقتراحك هنا...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _launchWhatsApp('اقتراح: ${controller.text}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}
