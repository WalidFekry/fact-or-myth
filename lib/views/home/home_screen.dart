import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/modern_bottom_nav.dart';
import '../../widgets/register_dialog.dart';
import '../daily_question/daily_question_screen.dart';
import '../free_questions/free_questions_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DailyQuestionScreen(),
    const FreeQuestionsScreen(),
    const LeaderboardScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    final authVM = context.read<AuthViewModel>();
    
    // Check if user needs to login for leaderboard or profile
    if ((index == 2 || index == 3) && !authVM.isLoggedIn) {
      _showLoginRequired(index);
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showLoginRequired(int targetIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('تسجيل الدخول مطلوب'),
        content: const Text('يجب تسجيل الدخول للوصول إلى هذه الميزة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final registered = await showRegisterDialog(
                context,
                onRegistered: () {
                  setState(() {
                    _currentIndex = targetIndex;
                  });
                },
              );
              if (registered == true && mounted) {
                setState(() {
                  _currentIndex = targetIndex;
                });
              }
            },
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
