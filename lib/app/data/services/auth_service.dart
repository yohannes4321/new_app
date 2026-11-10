import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../routes/app_routes.dart';
import 'notification_service.dart';

class AuthService extends GetxService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final _secureStorage = const FlutterSecureStorage();
  static const _tokenKey = 'token';
  static const _userDataKey = 'user_data';

  var isLoggedIn = false.obs;
  var token = "".obs;

  // 🔥 This will hold the MongoDB user data (username, _id, is_premium, etc.)
  var userProfile = <String, dynamic>{}.obs;

  // 🔥 NEW: Keep track of events joined in this session
  var joinedEventIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    hydrateSession();
    _initAuthListener();
  }

  Future<void> hydrateSession() async {
    await _restoreSecureSession();
  }

  Future<void> _restoreSecureSession() async {
    try {
      final savedToken = await _secureStorage.read(key: _tokenKey) ?? "";
      token.value = savedToken;
      isLoggedIn.value = false;

      final rawUser = await _secureStorage.read(key: _userDataKey);
      if (rawUser != null && rawUser.isNotEmpty) {
        final decoded = jsonDecode(rawUser);
        if (decoded is Map<String, dynamic>) {
          userProfile.value = decoded;
          joinedEventIds.clear();
          if (decoded['events_joined'] != null) {
            joinedEventIds.addAll(List<String>.from(decoded['events_joined']));
          }
        }
      }
      final user = _auth.currentUser;
      isLoggedIn.value =
          user != null &&
          user.emailVerified &&
          (userProfile['firebaseUid'] ?? userProfile['id']) == user.uid &&
          savedToken.isNotEmpty;
    } catch (_) {
      // If secure storage is unreadable/corrupt, start cleanly.
      token.value = "";
      isLoggedIn.value = false;
      userProfile.value = {};
      joinedEventIds.clear();
    }
  }

  // ✅ THIS IS THE MISSING METHOD
  void setUser(Map<String, dynamic> data) {
    userProfile.value = data;
    // Load already joined events if the backend sends them in the profile
    if (data['events_joined'] != null) {
      joinedEventIds.addAll(List<String>.from(data['events_joined']));
    }

    _secureStorage.write(
      key: _userDataKey,
      value: jsonEncode(Map<String, dynamic>.from(data)),
    );
  }

  bool isEventJoined(String id) => joinedEventIds.contains(id);

  void _initAuthListener() {
    _auth.idTokenChanges().listen((User? user) async {
      if (user != null) {
        token.value = await user.getIdToken() ?? "";

        await _secureStorage.write(key: _tokenKey, value: token.value);

        isLoggedIn.value =
            user.emailVerified &&
            (userProfile['firebaseUid'] ?? userProfile['id']) == user.uid;

        // Trigger FCM sync when user identity is confirmed.
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().syncTokenToBackend();
        }
      } else {
        // Do not force logout here. Session should only be cleared by explicit
        // user action (Profile -> Logout).
        isLoggedIn.value = false;
        token.value = '';
      }
    });
  }

  void logout() {
    token.value = "";
    isLoggedIn.value = false;
    userProfile.value = {};
    joinedEventIds.clear();

    _secureStorage.delete(key: _tokenKey);
    _secureStorage.delete(key: _userDataKey);

    // If session is wiped, make sure app lands on sign-in.
    final canNavigate = Get.key.currentState != null;
    if (canNavigate && Get.currentRoute != Routes.SIGN_IN) {
      Get.offAllNamed(Routes.SIGN_IN);
    }
  }

  String get authToken => token.value;
}
