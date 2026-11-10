import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../models/subscription_model.dart';
import '../api_constants.dart';

class SubscriptionRepository extends GetConnect {
  final _auth = Get.find<AuthService>();

  Map<String, String> _authHeaders({
    Map<String, String>? extraHeaders,
  }) {
    return {
      'Authorization': 'Bearer ${_auth.authToken}',
      'Accept': 'application/json', // Good practice to include
      if (extraHeaders != null) ...extraHeaders,
    };
  }

  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 40); // Increased for Render wake-up
    super.onInit();
  }

  // GET /api/subscription/plans
  Future<List<SubscriptionPlan>> getPlans() async {
    final res = await get("/subscription/plans", headers: _authHeaders());
    if (res.isOk) {
      final List data = res.body['data'] ??[];
      return data.map((e) => SubscriptionPlan.fromJson(e)).toList();
    }
    throw Exception(
      res.body?['message'] ?? "Failed to load subscription plans.",
    );
  }

  // POST /api/subscription/:planId/initiate
  Future<String> initiateSubscription(
    String planId,
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) async {
    if (planId.trim().isEmpty) {
      throw Exception("Missing subscription plan ID.");
    }

    final payload = Map<String, dynamic>.from(data);
    final cleanIdempotencyKey = idempotencyKey?.trim() ?? '';
    
    // 🔥 THE FIX: Pass the raw Map directly. Do NOT use jsonEncode.
    final res = await post(
      "/subscription/$planId/initiate",
      payload,
      headers: _authHeaders(
        extraHeaders: cleanIdempotencyKey.isNotEmpty
            ? {'X-Idempotency-Key': cleanIdempotencyKey}
            : null,
      ),
      // 🔥 THE FIX: This parameter tells Chrome exactly how to format the req.body
      contentType: 'application/json', 
    );

    if (res.isOk) {
      final dynamic checkoutUrl =
          res.body?['checkoutUrl'] ??
          res.body?['checkout_url'] ??
          res.body?['data']?['checkoutUrl'] ??
          res.body?['data']?['checkout_url'] ??
          '';

      if (checkoutUrl is String && checkoutUrl.isNotEmpty) {
        final txRef = Uri.tryParse(checkoutUrl)?.queryParameters['tx_ref'];
        debugPrint(
          '[SubscriptionRepository] initiateSubscription ok | planId=$planId | tx_ref=${txRef ?? 'n/a'}',
        );
        return checkoutUrl;
      }

      throw Exception("Payment URL is missing from subscription response.");
    }

    print('❌ WEB 500 ERROR DETAILS:');
    print('Status: ${res.statusCode}');
    print('Body: ${res.body}');
    throw Exception(
      res.body?['message'] ?? 'Failed to initialize payment.',
    );
  }

  Future<bool> hasActiveSubscription() async {
    final res = await get(
      "/subscription/my-subscription",
      headers: _authHeaders(),
    );

    if (!res.isOk) {
      debugPrint(
        '[SubscriptionRepository] hasActiveSubscription failed | status=${res.statusCode} | body=${res.body}',
      );
      throw Exception(
        res.body?['message'] ?? "Failed to verify subscription status.",
      );
    }

    final data = res.body?['data'];
    debugPrint(
      '[SubscriptionRepository] hasActiveSubscription ok | data=$data',
    );
    if (data == null) {
      return false;
    }

    if (data is Map<String, dynamic>) {
      final status = (data['status'] ?? '').toString().toLowerCase();
      debugPrint(
        '[SubscriptionRepository] subscription status resolved: "$status"',
      );
      if (status.isEmpty) {
        return true;
      }
      return status == 'active';
    }

    return true;
  }

  Future<bool> triggerSubscriptionVerification(String txRef) async {
    final ref = txRef.trim();
    if (ref.isEmpty) return false;

    try {
      debugPrint(
        '[SubscriptionRepository] triggerSubscriptionVerification start | tx_ref=$ref',
      );
      final res = await get('/payments/subscription/verify/$ref');
      debugPrint(
        '[SubscriptionRepository] triggerSubscriptionVerification done | status=${res.statusCode} | isOk=${res.isOk}',
      );
      return res.statusCode != null;
    } catch (_) {
      debugPrint(
        '[SubscriptionRepository] triggerSubscriptionVerification failed | tx_ref=$ref',
      );
      return false;
    }
  }

  // DELETE /api/subscription/:subscriptionId/cancel
  Future<bool> cancelSubscription() async {
    final res = await delete(
      "/subscription/current/cancel", 
      headers: _authHeaders(),
    );

    if (res.isOk) {
      return true;
    }

    throw Exception(res.body?['message'] ?? "Failed to cancel subscription.");
  }
}