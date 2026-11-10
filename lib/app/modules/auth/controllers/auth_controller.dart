import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/api_constants.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  static const String _baseUrl = '${ApiConstants.baseUrl}/auth';
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final _connect = GetConnect(timeout: const Duration(seconds: 30));
  final _authService = Get.find<AuthService>();

  var isLoading = false.obs;
  final isSendingVerification = false.obs;
  DateTime? _lastVerificationSent;

  void _showMessage(String title, String message, {Duration? duration}) {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Color(0xFF374151), fontSize: 14),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFF9FAFB),
      borderColor: const Color(0xFFD4AF37),
      borderWidth: 1,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: duration ?? const Duration(seconds: 5),
      boxShadows: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      if (error.code == 'too-many-requests') {
        return 'Firebase temporarily limited requests. Wait before trying again.';
      }
      return '${error.message ?? "Firebase request failed"} (${error.code})';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> sendVerificationEmail() async {
    if (isSendingVerification.value) return;
    if (_lastVerificationSent != null &&
        DateTime.now().difference(_lastVerificationSent!).inSeconds < 60) {
      _showMessage(
        'Please wait',
        'Wait 60 seconds before requesting another email.',
      );
      return;
    }
    final user = _auth.currentUser;
    if (user == null) {
      _showMessage('Session Expired', 'Please sign in again.');
      return;
    }

    isSendingVerification.value = true;
    try {
      await user.sendEmailVerification();
      _lastVerificationSent = DateTime.now();
      _showMessage(
        'Verification Sent',
        'Please check your email inbox and spam folder.',
      );
    } catch (error) {
      _lastVerificationSent = DateTime.now();
      _showMessage('Verification email failed', _errorMessage(error));
    } finally {
      isSendingVerification.value = false;
    }
  }

  Future<bool> ensureEmailVerifiedOrRedirect({bool notify = true}) async {
    final user = _auth.currentUser;
    if (user == null) {
      if (notify) {
        _showMessage('Session Expired', 'Please sign in again.');
      }
      Get.offAllNamed(Routes.SIGN_IN);
      return false;
    }

    await user.reload();
    final refreshedUser = _auth.currentUser;
    final verified = refreshedUser?.emailVerified == true;

    if (!verified) {
      if (notify) {
        _showMessage(
          'Email Not Verified',
          'Please verify your email to continue.',
        );
      }
      Get.toNamed(Routes.VERIFY_EMAIL);
      return false;
    }

    return true;
  }

  Future<void> verifyEmailAndContinue() async {
    isLoading(true);
    try {
      final verified = await ensureEmailVerifiedOrRedirect(notify: true);
      if (!verified) {
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        Get.offAllNamed(Routes.SIGN_IN);
        return;
      }

      await _completeBackendSession(user);
    } catch (error) {
      _showMessage('Error', _errorMessage(error));
    } finally {
      isLoading(false);
    }
  }

  Future<void> signOutToLogin() async {
    await _auth.signOut();
    _authService.logout();
    Get.offAllNamed(Routes.SIGN_IN);
  }

  Future<void> signUp(
    String username,
    String email,
    String password,
    String confirmPassword,
    String phone,
  ) async {
    if (isLoading.value) return;
    username = username.trim();
    email = email.trim();
    phone = phone.replaceAll(RegExp(r'\D'), '');
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty) {
      _showMessage('Registration', 'Please fill all required fields.');
      return;
    }
    if (username.length < 3 || username.length > 30) {
      _showMessage(
        'Registration',
        'Username must contain between 3 and 30 characters.',
      );
      return;
    }
    if (!GetUtils.isEmail(email)) {
      _showMessage('Registration', 'Enter a valid email address.');
      return;
    }
    if (!RegExp(r'^9\d{8}$').hasMatch(phone)) {
      _showMessage(
        'Registration',
        'Enter 9 digits after +251, starting with 9 (for example 912345678).',
      );
      return;
    }
    if (password.length < 6) {
      _showMessage(
        'Registration',
        'Password must contain at least 6 characters.',
      );
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Registration', 'The passwords do not match.');
      return;
    }

    final normalizedPhone = '+251$phone';

    isLoading(true);
    User? createdUser;
    bool databaseRequestStarted = false;
    bool databaseRejected = false;
    bool databaseSaved = false;
    try {
      // 1. Create user in Firebase
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      createdUser = credential.user;
      if (createdUser == null) throw Exception('Firebase returned no account.');
      await createdUser.sendEmailVerification();
      _lastVerificationSent = DateTime.now();

      String? idToken = await credential.user?.getIdToken();
      String? firebaseUid = credential.user?.uid;

      // 2. Sync with Backend
      final requestBody = <String, dynamic>{
        "username": username,
        "email": email,
        "password": password,
        "phone_number": normalizedPhone,
        "firebaseUid": firebaseUid,
      };

      databaseRequestStarted = true;
      final response = await _connect
          .post(
            '$_baseUrl/register',
            requestBody,
            headers: {"Authorization": "Bearer $idToken"},
          )
          .timeout(
            const Duration(seconds: 30),
          ); // ⏳ Give Render.com time to think

      // --- 🔥 FIX: NULL-SAFE RESPONSE HANDLING ---
      if (response.status.isOk && response.body != null) {
        databaseSaved = true;
        // Safe access to 'data'
        var userData = response.body['data'];
        if (userData != null) {
          _authService.setUser(userData);
        }
        await _syncProfileCache(idToken);
        Get.offAllNamed(Routes.VERIFY_EMAIL);
      } else {
        // If the server failed, we show a friendly message instead of crashing
        print("❌ BACKEND SYNC FAILED: Status ${response.statusCode}");
        print("❌ BODY: ${response.body}");

        String errorMessage = response.statusCode == null
            ? 'Cannot reach the backend. Check your connection and server.'
            : 'Registration failed (HTTP ${response.statusCode}).';

        // Safely check for message in body
        if (response.body != null &&
            response.body is Map &&
            response.body['message'] != null) {
          errorMessage = response.body['message'];
        }

        databaseRejected = response.statusCode == 400;
        throw Exception(errorMessage);
      }
    } catch (e) {
      var message = _errorMessage(e);
      if (createdUser != null && !databaseSaved) {
        if (!databaseRequestStarted || databaseRejected) {
          try {
            await createdUser.delete();
            _authService.logout();
            message +=
                ' The new Firebase account was deleted. Please register again.';
          } catch (cleanupError) {
            message +=
                ' Account cleanup failed: ${_errorMessage(cleanupError)}';
          }
        } else {
          message +=
              ' Database save could not be confirmed. The Firebase account was retained because the server may have saved it before the connection failed.';
        }
      }
      _showMessage(
        'Registration failed',
        message,
        duration: const Duration(seconds: 10),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> signIn(String email, String password) async {
    isLoading(true);
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser?.emailVerified != true) {
        _showMessage(
          'Verify Email',
          'Please verify your email before signing in.',
        );
        Get.offAllNamed(Routes.VERIFY_EMAIL);
        return;
      }

      await _completeBackendSession(refreshedUser!);
    } catch (e) {
      _showMessage('Login Error', _errorMessage(e));
    } finally {
      isLoading(false);
    }
  }

  Future<void> _completeBackendSession(User user) async {
    final String? idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Missing Firebase token. Please sign in again.');
    }

    final response = await _connect.post(
      '$_baseUrl/session',
      {"idToken": idToken, "firebaseUid": user.uid},
      headers: {"Authorization": "Bearer $idToken"},
    );

    if (response.status.isOk && response.body != null) {
      if (response.body['data'] != null) {
        _authService.setUser(Map<String, dynamic>.from(response.body['data']));
      }
      await _syncProfileCache(idToken);
      _authService.token.value = idToken;
      _authService.isLoggedIn.value = true;
      Get.offAllNamed(Routes.HOME);
      return;
    }

    await _auth.signOut();
    _authService.logout();
    final body = response.body;
    throw Exception(
      body is Map && body['message'] is String
          ? body['message']
          : 'Could not verify the backend session (HTTP ${response.statusCode ?? "unavailable"}).',
    );
  }

  Future<void> _syncProfileCache(String? idToken) async {
    if (idToken == null || idToken.isEmpty) return;

    try {
      final response = await _connect.get(
        '$_baseUrl/profile',
        headers: {"Authorization": "Bearer $idToken"},
      );

      if (!response.status.isOk || response.body == null) return;

      final profile = response.body['data'];
      if (profile is! Map) return;

      final merged = Map<String, dynamic>.from(_authService.userProfile);
      merged.addAll(Map<String, dynamic>.from(profile));
      _authService.setUser(merged);
    } catch (_) {
      // Profile sync is best-effort; signup/signin should still continue.
    }
  }
}
