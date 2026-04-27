import 'dart:async';
import 'package:fact_or_myth/viewmodels/auth_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'data/services/notification_service.dart';
import 'firebase_options.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/home/home_screen.dart';
import 'views/notification_permission/notification_permission_screen.dart';

// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  // Run app in error zone to catch all errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Crashlytics
    // Only enable Crashlytics in release mode
    if (kReleaseMode) {
      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } else {
      // In debug mode, print errors to console
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (kDebugMode) {
          print('Flutter Error: ${details.exception}');
          print('Stack trace: ${details.stack}');
        }
      };
    }

    //Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Setup dependency injection
    await setupServiceLocator();

    // Initialize notification service
    final notificationService = getIt<NotificationService>();
    await notificationService.initialize();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    runApp(const MyApp());
  }, (error, stack) {
    // Catch errors that occur outside of Flutter framework
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } else {
      if (kDebugMode) {
        print('Async Error: $error');
        print('Stack trace: $stack');
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<ThemeViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<AuthViewModel>()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) {
          return MaterialApp(
            title: 'حقيقة ولا خرافة؟',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVM.themeMode,
            home: const InitialScreen(),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

// Check if first time and route accordingly
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool(AppConstants.keyIsFirstTime) ?? true;
    final notificationPermissionShown = prefs.getBool(AppConstants.keyNotificationPermissionShown) ?? false;
    
    if (mounted) {
      if (isFirstTime) {
        // First time - show onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else if (!notificationPermissionShown) {
        // Not first time but notification permission not shown yet
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NotificationPermissionScreen()),
        );
      } else {
        // Normal flow - go to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show minimal loading while checking
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
