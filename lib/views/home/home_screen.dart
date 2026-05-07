import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/challenge/challenge_play_screen.dart';
import '../../features/challenge/challenge_screen.dart';
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
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _lastHandledUri;

  final List<Widget> _screens = [
    const DailyQuestionScreen(),
    const FreeQuestionsScreen(),
    const ChallengeScreen(),
    const LeaderboardScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    // Handle initial link if app was opened via deep link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }
    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Error listening to deep links: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (_lastHandledUri?.toString() == uri.toString()) {
      return;
    }
    _lastHandledUri = uri;

    debugPrint('Received deep link: $uri');

    final segments = uri.pathSegments;

    if (segments.isEmpty) return;

    final chIndex = segments.indexOf('ch');

    if (chIndex != -1 && segments.length > chIndex + 1) {
      final questionId = int.tryParse(segments[chIndex + 1]);
      final userId = (segments.length > chIndex + 2)
          ? int.tryParse(segments[chIndex + 2])
          : null;

      if (questionId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengePlayScreen(
                questionId: questionId,
                userId: userId,
              ),
            ),
          );
        });
      }
    }
  }

  void _onTabTapped(int index) {
    final authVM = context.read<AuthViewModel>();

    // Check if user needs to login for leaderboard or profile
    if ((index == 3 || index == 4) && !authVM.isLoggedIn) {
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
