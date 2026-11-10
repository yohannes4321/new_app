import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:church_app/app/routes/app_routes.dart';
import '../api_constants.dart';
import 'auth_service.dart';

class AppNotificationItem {
  final String title;
  final String body;
  final DateTime receivedAt;

  const AppNotificationItem({
    required this.title,
    required this.body,
    required this.receivedAt,
  });
}

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final GetConnect _connect = GetConnect();
  final notifications = <AppNotificationItem>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _connect.baseUrl = ApiConstants.baseUrl;
    _connect.timeout = const Duration(seconds: 20);
    _initPushNotifications();
  }

  Future<void> _initPushNotifications() async {
    // 1. Request Permission from User (iOS/Web requires this, Android 13+ requires this)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permissions');
    } else {
      print('⚠️ User declined notification permissions');
    }

    // 2. Listen for Token Refreshes (If Firebase rotates the token, send new one to backend)
    _fcm.onTokenRefresh.listen((String newFcmToken) {
      syncTokenToBackend(specificToken: newFcmToken);
    });

    // 3. Handle FOREGROUND Messages (When the app is open and running)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 FOREGROUND NOTIFICATION RECEIVED");
      _cacheIncomingMessage(message);
      if (message.notification != null) {
        Get.closeCurrentSnackbar();
        Get.snackbar(
          '',
          message.notification!.body ??
              message.notification!.title ??
              "Church Update",
          snackPosition: SnackPosition.TOP,
          titleText: const SizedBox.shrink(),
          icon: const SizedBox.shrink(),
          shouldIconPulse: false,
          duration: const Duration(seconds: 5),
          // If they tap the snackbar, route them!
          onTap: (_) => _handleSmartRouting(message),
        );
      }
    });

    // 4. Handle BACKGROUND Taps (When app is minimized and user taps the push notification)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _cacheIncomingMessage(message);
      _handleSmartRouting(message);
    });

    // 5. Handle TERMINATED Taps (When app is completely closed and user taps notification)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _cacheIncomingMessage(initialMessage);
      // Small delay to allow GetX routes to initialize before jumping
      Future.delayed(const Duration(milliseconds: 800), () {
        _handleSmartRouting(initialMessage);
      });
    }
  }

  // --- THE BACKEND CONTRACT: POST /api/users/fcm-token ---
  Future<void> syncTokenToBackend({String? specificToken}) async {
    final auth = Get.find<AuthService>();

    // Safety check: Don't send if we aren't logged in
    if (!auth.isLoggedIn.value || auth.authToken.isEmpty) {
      print("⚠️ FCM Sync skipped: User not logged in.");
      return;
    }

    // Get the FCM token for this specific device
    final String? fcmToken = specificToken ?? await _fcm.getToken();
    if (fcmToken == null) {
      print("❌ FCM Sync skipped: Could not generate FCM token.");
      return;
    }

    try {
      print("--- 📡 SYNCING FCM TOKEN TO BACKEND ---");
      final res = await _connect.post(
        "/users/fcm-token",
        {"token": fcmToken},
        headers: {
          'Authorization': 'Bearer ${auth.authToken}',
          'Content-Type': 'application/json',
        },
      );

      if (res.isOk) {
        print("✅ FCM Token synced successfully!");
      } else {
        print(
          "❌ FCM Sync Failed: Status ${res.statusCode} | Body: ${res.body}",
        );
      }
    } catch (e) {
      print("❌ FCM Sync Error: $e");
    }
  }

  // --- SMART ROUTING LOGIC ---
  // Because your backend doesn't send hidden data payloads, we read the body text!
  void _handleSmartRouting(RemoteMessage message) {
    String body = (message.notification?.body ?? "").toLowerCase();
    String title = (message.notification?.title ?? "").toLowerCase();

    String contentToRead = "$title $body"; // Read both just in case

    print("🧭 SMART ROUTER TRIGGERED: Analyzing '$contentToRead'");

    if (contentToRead.contains("live")) {
      Get.toNamed(Routes.HOME); // Go home to see the live player
    } else if (contentToRead.contains("sermon")) {
      Get.toNamed(Routes.SERMONS);
    } else if (contentToRead.contains("event")) {
      Get.toNamed(Routes.EVENTS);
    } else if (contentToRead.contains("thank you") ||
        contentToRead.contains("subscription")) {
      Get.toNamed(
        Routes.PROFILE,
      ); // Send to profile to see their history/status
    } else {
      print("🤷‍♂️ No specific keyword found, staying on current screen.");
    }
  }

  void openNotificationsInbox() {
    markAllAsRead();
    Get.toNamed(Routes.NOTIFICATIONS);
  }

  void markAllAsRead() {
    unreadCount.value = 0;
  }

  void clearNotifications() {
    notifications.clear();
    unreadCount.value = 0;
  }

  void openNotification(AppNotificationItem item) {
    markAllAsRead();
    final body = item.body.toLowerCase();
    final title = item.title.toLowerCase();
    final contentToRead = '$title $body';

    if (contentToRead.contains('live')) {
      Get.toNamed(Routes.HOME);
    } else if (contentToRead.contains('sermon')) {
      Get.toNamed(Routes.SERMONS);
    } else if (contentToRead.contains('event')) {
      Get.toNamed(Routes.EVENTS);
    } else if (contentToRead.contains('thank you') ||
        contentToRead.contains('subscription')) {
      Get.toNamed(Routes.PROFILE);
    }
  }

  void _cacheIncomingMessage(RemoteMessage message) {
    final title =
        message.notification?.title ??
        message.data['title']?.toString() ??
        'Church Update';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    notifications.insert(
      0,
      AppNotificationItem(title: title, body: body, receivedAt: DateTime.now()),
    );
    unreadCount.value += 1;
  }
}
