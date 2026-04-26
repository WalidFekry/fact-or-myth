import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

  NotificationService(
    this._firebaseMessaging,
    this._storageService,
    this._apiService,
  );

  // TASK 2: Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission on iOS
      await _requestIOSPermission();

      // Get initial FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _storageService.saveFCMToken(token);
        if (kDebugMode) {
          print('📱 FCM Token: $token');
        }
      }

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _storageService.saveFCMToken(newToken);
        // Save to backend if user is logged in
        saveFCMTokenToBackend();
      });

      // TASK 2: Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification (terminated state)
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
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

  // Request iOS permission
  Future<void> _requestIOSPermission() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // TASK 2: Request notification permission
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

      if (granted) {
        // Get and save token
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _storageService.saveFCMToken(token);
        }
      }

      return granted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error requesting permission: $e');
      }
      return false;
    }
  }

  // TASK 3: Subscribe to topics
  Future<void> subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('daily_questions');
      await _firebaseMessaging.subscribeToTopic('quotes');
      await _firebaseMessaging.subscribeToTopic('app_updates');
      
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
      await _firebaseMessaging.unsubscribeFromTopic('daily_questions');
      await _firebaseMessaging.unsubscribeFromTopic('quotes');
      await _firebaseMessaging.unsubscribeFromTopic('app_updates');
      
      if (kDebugMode) {
        print('✅ Unsubscribed from all topics');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unsubscribing from topics: $e');
      }
    }
  }

  // TASK 2: Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 Foreground message received: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // You can show in-app notification here
    // For now, we'll just log it
    // In production, you might want to show a snackbar or dialog
  }

  // TASK 2: Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 Notification tapped: ${message.messageId}');
      print('Data: ${message.data}');
    }

    // TASK 6: Handle different notification types
    final notificationType = message.data['type'] as String?;
    
    switch (notificationType) {
      case 'daily_question':
        // Navigate to daily question screen
        // You can use a navigation service or global key
        break;
      case 'quote':
        // Show quote dialog or navigate to quotes screen
        break;
      case 'app_update':
        // Navigate to update screen or show dialog
        break;
      default:
        // Default behavior
        break;
    }
  }

  // TASK 5: Save FCM token to backend
  Future<void> saveFCMTokenToBackend() async {
    try {
      final userId = _storageService.getUserId();
      final token = await _storageService.getFCMToken();

      if (userId != null && token != null) {
        await _apiService.post('/save-fcm-token', {
          'user_id': userId,
          'fcm_token': token,
        });

        if (kDebugMode) {
          print('✅ FCM token saved to backend');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving FCM token to backend: $e');
      }
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // Get FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // TASK 8: Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    await _storageService.setNotificationsEnabled(enabled);
    
    if (enabled) {
      await subscribeToTopics();
      await saveFCMTokenToBackend();
    } else {
      await unsubscribeFromTopics();
    }
  }
}
