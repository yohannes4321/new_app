import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import '../api_constants.dart';
import '../models/event_registration_model.dart';
import '../models/payment_history_model.dart';

class ProfileRepository extends GetConnect {
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    super.onInit();
  }

  // GET /api/auth/profile
  Future<Map<String, dynamic>?> getProfileDetails() async {
    final res = await get(
      "/auth/profile",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );
    if (res.isOk) return res.body['data'];
    return null;
  }

  // GET /api/auth/stats
  Future<Map<String, dynamic>?> getProfileStats() async {
    final res = await get(
      "/auth/stats",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );
    if (res.isOk) return res.body['data'];
    return null;
  }

  Future<Map<String, dynamic>?> uploadProfileImage(File imageFile) async {
    final headers = {'Authorization': 'Bearer ${_auth.authToken}'};
    final payload = FormData({
      'profile_image': MultipartFile(
        imageFile,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      ),
    });

    final putRes = await put('/auth/profile', payload, headers: headers);
    if (putRes.isOk && putRes.body != null) return putRes.body['data'];

    final patchRes = await patch('/auth/profile', payload, headers: headers);
    if (patchRes.isOk && patchRes.body != null) return patchRes.body['data'];

    return null;
  }

  // GET /api/payments/history
  Future<PaymentHistoryResponse?> getPaymentHistory() async {
    final res = await get(
      "/payments/history",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );
    if (res.isOk && res.body['data'] != null) {
      return PaymentHistoryResponse.fromJson(res.body['data']);
    }
    return null;
  }

  // GET /api/events/my-events
  Future<List<EventRegistrationModel>> getMyEventHistory() async {
    // Ensure a fresh token exists before this protected request.
    if (_auth.authToken.isEmpty) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _auth.token.value = await firebaseUser.getIdToken(true) ?? '';
      }
    }

    Future<Response<dynamic>> send() {
      return get(
        '/events/my-events',
        headers: {'Authorization': 'Bearer ${_auth.authToken}'},
      );
    }

    var res = await send();

    // Retry once on auth failure with a refreshed Firebase token.
    if (res.statusCode == 401 || res.statusCode == 403) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _auth.token.value = await firebaseUser.getIdToken(true) ?? '';
        res = await send();
      }
    }

    if (!res.isOk || res.body == null) {
      return [];
    }

    final dynamic body = res.body;
    List<dynamic> rawList = const [];

    if (body is Map && body['data'] is List) {
      rawList = body['data'] as List<dynamic>;
    } else if (body is List) {
      rawList = body;
    }

    if (rawList.isEmpty) return [];

    return rawList
        .whereType<Map>()
        .map(
          (e) => EventRegistrationModel.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }
}
