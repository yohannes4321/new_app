import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:church_app/app/modules/store/views/payment_webview.dart';
import 'package:church_app/app/widgets/app_feedback.dart';
import '../../../data/services/donations_repository.dart';
import '../../../data/services/auth_service.dart';

class DonationController extends GetxController {
  final repository = Get.find<DonationsRepository>();
  final authService = Get.find<AuthService>();

  final amountController = TextEditingController();
  final messageController = TextEditingController();

  var selectedAmount = 0.obs;
  var isLoading = false.obs;

  void selectAmount(int amount) {
    selectedAmount.value = amount;
    amountController.text = amount.toString();
  }

  Future<void> startDonation() async {
    if (amountController.text.trim().isEmpty) {
      showAppFeedback("Missing Info", "Please enter an amount to give.");
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      showAppFeedback(
        "Invalid Amount",
        "Please enter a valid donation amount.",
        type: AppFeedbackType.warning,
      );
      return;
    }

    isLoading(true);
    try {
      final user = authService.userProfile;
      final firebaseUser = FirebaseAuth.instance.currentUser;

      final String email = (user['email'] ?? firebaseUser?.email ?? '')
          .toString();
      final String username =
          (user['username'] ?? firebaseUser?.displayName ?? 'Church Member')
              .toString();
      final String token = authService.authToken;

      if (email.isEmpty || token.isEmpty) {
        showAppFeedback(
          "Account Error",
          "Please log out and log in again to sync your account.",
          type: AppFeedbackType.error,
        );
        return;
      }

      final parts = username
          .trim()
          .split(' ')
          .where((p) => p.isNotEmpty)
          .toList();
      final String firstName = parts.isNotEmpty ? parts.first : 'Church';
      final String lastName = parts.length > 1
          ? parts.sublist(1).join(' ')
          : 'Member';

      final Map<String, dynamic> payload = {
        "amount": double.tryParse(amountController.text) ?? 0.0,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "message": messageController.text,
      };

      final checkoutUrl = await repository.initializeDonation(payload);
      if (checkoutUrl.isEmpty) {
        throw Exception('Invalid checkout URL returned by server.');
      }

      final result = await Get.to(
        () => const PaymentWebView(),
        arguments: checkoutUrl,
      );
      if (result == true) {
        showAppFeedback(
          "Processing",
          "Your donation is being verified.",
          type: AppFeedbackType.success,
        );
      }
    } catch (e) {
      showAppFeedback("Giving Error", e, type: AppFeedbackType.error);
    } finally {
      isLoading(false);
    }
  }
}
