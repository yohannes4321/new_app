import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:church_app/app/widgets/app_feedback.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/subscription_repository.dart';
import '../../store/views/payment_webview.dart';

class SubscriptionsController extends GetxController {
  final repository = Get.find<SubscriptionRepository>();
  final authService = Get.find<AuthService>();
  final _storage = GetStorage();
  static const _pendingTxRefKey = 'pending_subscription_tx_ref';

  final isLoading = false.obs;
  final isCheckoutInProgress = false.obs;
  final isActivationPending = false.obs;
  final plans = <SubscriptionPlan>[].obs;

  // 🔥 NEW: State for double-charge protection
  final isAlreadyPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future(() async {
      _captureWebReturnState();
      await checkCurrentStatus();
      await _resumePendingWebCheckout();
    });
  }

  // 1. Check if user is already Premium before loading plans
  Future<void> checkCurrentStatus() async {
    isLoading(true);
    try {
      final active = await repository.hasActiveSubscription();
      isAlreadyPremium.value = active;

      // Mobile builds are consumption-only: no external checkout is exposed.
      if (!active && kIsWeb) {
        // Only fetch plans if they need to buy one
        await fetchPlans();
      }
    } catch (e) {
      showAppFeedback(
        'Error',
        'Could not verify subscription status.',
        type: AppFeedbackType.error,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPlans() async {
    try {
      final result = await repository.getPlans();
      plans.assignAll(result);
    } catch (e) {
      showAppFeedback('Plans Error', e, type: AppFeedbackType.error);
    }
  }

  Future<void> _refreshPremiumFlagFromServer() async {
    final active = await repository.hasActiveSubscription();
    isAlreadyPremium.value = active; // Update local UI state
    if (active) {
      isActivationPending(false);
      _clearPendingWebTxRef();
    }

    final updated = Map<String, dynamic>.from(authService.userProfile);
    updated['is_premium'] = active;
    authService.setUser(updated);
  }

  Future<bool> _waitForPremiumActivation({
    int attempts = 5,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < attempts; i++) {
      try {
        final active = await repository.hasActiveSubscription();
        debugPrint(
          '[SubscriptionsController] activation poll ${i + 1}/$attempts | active=$active',
        );
        if (active) {
          await _refreshPremiumFlagFromServer();
          return true;
        }
      } catch (_) {}

      if (i < attempts - 1) {
        await Future.delayed(interval);
      }
    }
    return false;
  }

  void _startBackgroundActivationPolling() {
    Future(() async {
      final activated = await _waitForPremiumActivation(
        attempts: 6,
        interval: const Duration(seconds: 3),
      );

      if (activated) {
        isActivationPending(false);
        _clearPendingWebTxRef();
        showAppFeedback(
          'Premium Activated',
          'Your premium access is now active.',
          type: AppFeedbackType.success,
        );
        return;
      }

      isActivationPending(false);
    });
  }

  void _savePendingWebTxRef(String txRef) {
    if (txRef.trim().isEmpty) return;
    _storage.write(_pendingTxRefKey, txRef.trim());
  }

  void _clearPendingWebTxRef() {
    _storage.remove(_pendingTxRefKey);
  }

  String _webRouteUrl(String route, {String? status}) {
    final base = Uri.base.replace(queryParameters: {}, fragment: '').toString();
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final statusQuery = status == null ? '' : '?status=$status';
    return '$normalizedBase/#$route$statusQuery';
  }

  void _captureWebReturnState() {
    if (!kIsWeb) return;

    final qp = Uri.base.queryParameters;
    final txRef = (qp['tx_ref'] ?? qp['trx_ref'] ?? '').toString();
    if (txRef.isNotEmpty) {
      _savePendingWebTxRef(txRef);
    }
  }

  Future<void> _resumePendingWebCheckout() async {
    if (!kIsWeb) return;
    if (isAlreadyPremium.value) {
      _clearPendingWebTxRef();
      return;
    }

    final pendingTxRef = (_storage.read(_pendingTxRefKey) ?? '').toString();
    if (pendingTxRef.isEmpty) return;

    isActivationPending(true);
    try {
      await repository.triggerSubscriptionVerification(pendingTxRef);
      final activated = await _waitForPremiumActivation(
        attempts: 12,
        interval: const Duration(seconds: 3),
      );

      if (activated) {
        _clearPendingWebTxRef();
        showAppFeedback(
          'Success',
          'Welcome to Premium!',
          type: AppFeedbackType.success,
        );
      }
    } catch (_) {
      // Keep pending tx_ref for another retry when user revisits this page.
    } finally {
      isActivationPending(false);
    }
  }

  Future<void> _openCheckoutOnWeb(String checkoutUrl) async {
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null) {
      throw Exception('Invalid checkout URL returned by server.');
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: 'chapa_checkout',
    );
    if (!launched) {
      throw Exception('Could not open payment checkout page.');
    }
  }

  Future<void> subscribe(SubscriptionPlan plan) async {
    if (!kIsWeb) {
      showAppFeedback(
        'Already have an account?',
        'Sign in with the account used for your purchase to access premium content.',
        type: AppFeedbackType.info,
      );
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      showAppFeedback(
        'Sign In Required',
        'Please sign in to continue.',
        type: AppFeedbackType.warning,
      );
      Get.toNamed(Routes.SIGN_IN);
      return;
    }

    await firebaseUser.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (refreshedUser?.emailVerified != true) {
      showAppFeedback(
        'Verify Email',
        'Please verify your email before purchasing a subscription.',
        type: AppFeedbackType.warning,
      );
      Get.toNamed(Routes.VERIFY_EMAIL);
      return;
    }

    if (authService.userProfile.isEmpty) {
      showAppFeedback(
        'Sync Required',
        'Please log out and log in again to sync your account details.',
        type: AppFeedbackType.error,
      );
      return;
    }

    // 🛡️ DOUBLE-CHARGE GUARD
    if (isAlreadyPremium.value) {
      showAppFeedback(
        'Already Premium',
        'You already have an active subscription.',
        type: AppFeedbackType.warning,
      );
      return;
    }

    if (isCheckoutInProgress.value) {
      showAppFeedback(
        'Please wait',
        'A subscription checkout is already in progress.',
        type: AppFeedbackType.info,
      );
      return;
    }

    if (isActivationPending.value) {
      showAppFeedback(
        'Activation Pending',
        'Your payment is being confirmed. Please wait a moment.',
        type: AppFeedbackType.info,
      );
      return;
    }

    final token = authService.authToken;
    if (token.isEmpty) return;

    final profile = authService.userProfile;
    final String email = (profile['email'] ?? firebaseUser.email ?? '')
        .toString();
    final String username =
        (profile['username'] ?? firebaseUser.displayName ?? 'Church Member')
            .toString();

    final parts = username
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    final String firstName = parts.isNotEmpty ? parts.first : 'Church';
    final String lastName = parts.length > 1
        ? parts.sublist(1).join(' ')
        : 'Member';

    isLoading(true);
    isCheckoutInProgress(true);
    try {
      // Recheck against server right before checkout init to reduce stale-state races.
      final activeNow = await repository.hasActiveSubscription();
      if (activeNow) {
        await _refreshPremiumFlagFromServer();
        showAppFeedback(
          'Already Premium',
          'You already have an active subscription.',
          type: AppFeedbackType.warning,
        );
        return;
      }

      final payload = <String, dynamic>{
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        if (kIsWeb) ...{
          // Best-effort return URLs for payment providers/backends that support them.
          'return_url': _webRouteUrl(Routes.SUBSCRIPTIONS, status: 'success'),
          'success_url': _webRouteUrl(Routes.SUBSCRIPTIONS, status: 'success'),
          'cancel_url': _webRouteUrl(Routes.SUBSCRIPTIONS, status: 'cancel'),
        },
      };

      final checkoutUrl = await repository.initiateSubscription(
        plan.id,
        payload,
      );

      final txRef = Uri.parse(checkoutUrl).queryParameters['tx_ref'] ?? '';
      debugPrint(
        '[SubscriptionsController] checkout initialized | tx_ref=${txRef.isEmpty ? 'n/a' : txRef}',
      );

      if (kIsWeb) {
        if (txRef.isNotEmpty) {
          _savePendingWebTxRef(txRef);
        }
        await _openCheckoutOnWeb(checkoutUrl);

        if (txRef.isNotEmpty) {
          final verificationTriggered = await repository
              .triggerSubscriptionVerification(txRef);
          debugPrint(
            '[SubscriptionsController] web fallback verify triggered=$verificationTriggered',
          );
        }

        isActivationPending(true);
        showAppFeedback(
          'Checkout Opened',
          'Complete payment in the opened page. We will verify your subscription in the background.',
          type: AppFeedbackType.info,
        );
        _startBackgroundActivationPolling();
        return;
      }

      final result = await Get.to(
        () => const PaymentWebView(),
        arguments: checkoutUrl,
      );
      debugPrint('[SubscriptionsController] webview result=$result');

      if (txRef.isNotEmpty) {
        final verificationTriggered = await repository
            .triggerSubscriptionVerification(txRef);
        debugPrint(
          '[SubscriptionsController] fallback verify triggered=$verificationTriggered',
        );
      }

      if (result == true) {
        isActivationPending(true);
        final activated = await _waitForPremiumActivation();
        if (activated) {
          showAppFeedback(
            'Success',
            'Welcome to Premium!',
            type: AppFeedbackType.success,
          );
          isActivationPending(false);
        } else {
          showAppFeedback(
            'Payment Received',
            'We are finalizing your premium activation. Please wait...',
            type: AppFeedbackType.info,
          );
          _startBackgroundActivationPolling();
        }
      } else if (result == false) {
        await _refreshPremiumFlagFromServer();
        showAppFeedback(
          'Payment Incomplete',
          'Subscription payment was not completed.',
          type: AppFeedbackType.warning,
        );
      } else {
        // User may have closed the webview manually after payment.
        isActivationPending(true);
        final activated = await _waitForPremiumActivation(
          attempts: 10,
          interval: const Duration(seconds: 3),
        );
        if (activated) {
          showAppFeedback(
            'Success',
            'Welcome to Premium!',
            type: AppFeedbackType.success,
          );
          isActivationPending(false);
        } else {
          showAppFeedback(
            'Checking Payment',
            'We are still confirming your subscription status.',
            type: AppFeedbackType.info,
          );
          _startBackgroundActivationPolling();
        }
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isConflict =
          msg.contains('409') ||
          msg.contains('already') ||
          msg.contains('active subscription');
      if (isConflict) {
        await _refreshPremiumFlagFromServer();
        showAppFeedback(
          'Already Premium',
          'You already have an active subscription.',
          type: AppFeedbackType.warning,
        );
        return;
      }

      showAppFeedback('Subscription Error', e, type: AppFeedbackType.error);
    } finally {
      isCheckoutInProgress(false);
      isLoading(false);
    }
  }

  // 2. Action to Cancel Current Plan
  Future<void> cancelMyPlan() async {
    isLoading(true);
    try {
      final success = await repository.cancelSubscription();
      if (success) {
        await _refreshPremiumFlagFromServer();
        showAppFeedback(
          'Cancelled',
          'Your subscription has been stopped.',
          type: AppFeedbackType.info,
        );
        await fetchPlans(); // Load store plans again so they can re-subscribe later
      }
    } catch (e) {
      showAppFeedback('Error', e, type: AppFeedbackType.error);
    } finally {
      isLoading(false);
    }
  }
}
