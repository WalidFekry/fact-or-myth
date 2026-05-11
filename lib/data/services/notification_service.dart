import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/utils/commen_utils.dart';
import '../../views/home/home_screen.dart';
import 'storage_service.dart';
import 'api_service.dart';

// TASK 2: Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  if (kDebugMode) {
    print('📱 Background message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final StorageService _storageService;
  final ApiService _apiService;
  final GlobalKey<NavigatorState>? navigatorKey;

  // Store pending notification for cold start
  RemoteMessage? _pendingNotification;
  bool _isAppReady = false;

  NotificationService(
    this._firebaseMessaging,
    this._storageService,
    this._apiService, {
    this.navigatorKey,
  });

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission on iOS
      if (Platform.isIOS) {
        await _requestIOSPermission();
      }

      // Get initial FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('📱 FCM Token: $token');
        }
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleNotificationTap);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification (terminated state)
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print('🚀 App opened from TERMINATED state via notification');
          print('📱 Initial message: ${initialMessage.messageId}');
          print('📊 Data: ${initialMessage.data}');
        }
        
        // Store the notification to handle after app is ready
        _pendingNotification = initialMessage;
      }

      if (kDebugMode) {
        print('✅ Notification service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing notifications: $e');
      }
    }
  }

  // Mark app as ready and handle pending notification
  void markAppReady() {
    _isAppReady = true;
    
    if (_pendingNotification != null) {
      if (kDebugMode) {
        print('✅ App is now ready, handling pending notification');
      }
      
      // Delay navigation slightly to ensure UI is fully rendered
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(_pendingNotification!);
        _pendingNotification = null;
      });
    }
  }

  // Request iOS permission
  Future<void> _requestIOSPermission() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Request notification permission
  Future<bool> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      return granted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error requesting permission: $e');
      }
      return false;
    }
  }

  // Subscribe to topics
  Future<void> subscribeToTopics() async {
    try {
      if (Platform.isAndroid) {
        await _firebaseMessaging.subscribeToTopic('android');
      } else {
        await _firebaseMessaging.subscribeToTopic('ios');
      }

      await _firebaseMessaging.subscribeToTopic('all');

      if (kDebugMode) {
        print('✅ Subscribed to all topics');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subscribing to topics: $e');
      }
    }
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopics() async {
    try {
      if (Platform.isAndroid) {
        await _firebaseMessaging.unsubscribeFromTopic('android');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic('ios');
      }

      await _firebaseMessaging.unsubscribeFromTopic('all');

      if (kDebugMode) {
        print('✅ Unsubscribed from all topics');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unsubscribing from topics: $e');
      }
    }
  }


  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('🔔 Notification tapped: ${message.messageId}');
      print('📊 Data: ${message.data}');
      print('🎯 App ready: $_isAppReady');
    }

    // If app is not ready yet, store for later
    if (!_isAppReady) {
      if (kDebugMode) {
        print('⏳ App not ready, storing notification for later');
      }
      _pendingNotification = message;
      return;
    }

    // Handle different notification types
    final clickAction = message.data['click_action'] as String?;
    
    if (kDebugMode) {
      print('🎬 Click action: $clickAction');
    }
    
    switch (clickAction) {
      case 'open_url':
        final url = message.data['url'] as String?;
        if (url != null && url.isNotEmpty) {
          CommonUtils.launchURL(url);
          if (kDebugMode) {
            print('🌐 Opening URL: $url');
          }
        }
        break;
      case 'home':
        if (kDebugMode) {
          print('🏠 Navigating to Home tab');
        }
        _navigateToTab(0);
        break;
      case 'free':
        if (kDebugMode) {
          print('🆓 Navigating to Free Questions tab');
        }
        _navigateToTab(1);
        break;
      case 'challenge':
        if (kDebugMode) {
          print('⚔️ Navigating to Challenge tab');
        }
        _navigateToTab(2);
        break;
      default:
        if (kDebugMode) {
          print('ℹ️ No specific action, using default behavior');
        }
        // Default: navigate to home
        _navigateToTab(0);
        break;
    }
  }

  // Navigate to specific tab in HomeScreen
  void _navigateToTab(int tabIndex) {
    // Wait for navigator to be ready
    if (navigatorKey?.currentContext == null) {
      if (kDebugMode) {
        print('⚠️ Navigator context not available, retrying...');
      }
      
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _navigateToTab(tabIndex);
      });
      return;
    }

    final context = navigatorKey!.currentContext!;
    
    try {
      // Navigate to HomeScreen with specific tab
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(initialIndex: tabIndex),
        ),
        (route) => false,
      );
      
      if (kDebugMode) {
        print('✅ Successfully navigated to tab: $tabIndex');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation error: $e');
      }
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    // Request permission
    final granted = await requestPermission();
    if (granted) {
      if (enabled) {
        await subscribeToTopics();
      } else {
        await unsubscribeFromTopics();
      }
    }
    await _storageService.setNotificationsEnabled(enabled);
  }
}
