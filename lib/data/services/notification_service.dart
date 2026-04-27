import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/commen_utils.dart';
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

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission on iOS
      if(Platform.isIOS) {
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
      if(Platform.isAndroid){
        await _firebaseMessaging.subscribeToTopic('android');
      }else{
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
      if(Platform.isAndroid){
        await _firebaseMessaging.unsubscribeFromTopic('android');
      }else{
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

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 Foreground message received: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 Notification tapped: ${message.messageId}');
      print('Data: ${message.data}');
    }

    // Handle different notification types
    final clickAction = message.data['click_action'] as String?;
    
    switch (clickAction) {
      case 'open_url':
       final url = message.data['url'] as String;
       if (url.isNotEmpty) {
         CommonUtils.launchURL(url);
       }
        break;
      default:
        // Default behavior
        break;
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
