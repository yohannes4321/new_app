import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:church_app/app/routes/app_routes.dart';
import 'package:church_app/app/widgets/main_bottom_nav.dart';
import '../controllers/subscriptions_controller.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const MainBottomNav(
        activeRoute: Routes.SUBSCRIPTIONS,
      ),
      appBar: AppBar(
        title: const Text(
          'Premium Access',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.plans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4C734D)),
          );
        }

        // 🛡️ THE PROTECTION UI: If already premium, show Dashboard
        if (controller.isAlreadyPremium.value) {
          return _buildManageDashboard();
        }

        if (!kIsWeb) {
          return _buildMobileAccessPanel();
        }

        // If free, show the web plans
        if (controller.plans.isEmpty) {
          return const Center(child: Text('No active plans found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.plans.length,
          itemBuilder: (context, index) {
            final plan = controller.plans[index];
            return _buildPlanCard(plan);
          },
        );
      }),
    );
  }

  Widget _buildMobileAccessPanel() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            children: [
              Icon(Icons.verified_outlined, size: 56, color: Color(0xFF2E6B44)),
              SizedBox(height: 16),
              Text('Premium access', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text('Sign in with the same account you use for Mission For Nation purchases. Your access is checked securely from the server.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.45)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const ListTile(leading: Icon(Icons.lock_outline, color: Color(0xFF2E6B44)), title: Text('No payment details in the app'), subtitle: Text('Your account and entitlements stay protected.')),
        const ListTile(leading: Icon(Icons.sync_outlined, color: Color(0xFF2E6B44)), title: Text('Access follows your account'), subtitle: Text('Refresh this page after signing in on another device.')),
      ],
    );
  }

  // 🔥 NEW: The Dashboard for Premium Users
  Widget _buildManageDashboard() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user, size: 80, color: Color(0xFF4C734D)),
          const SizedBox(height: 20),
          const Text(
            "You are a Premium Member!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "You have full access to all archived sermons and exclusive teachings.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4C734D),
                side: const BorderSide(color: Color(0xFF4C734D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Cancel Subscription"),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    Get.defaultDialog(
      title: "Cancel Subscription?",
      middleText: "Are you sure you want to lose access to Premium teachings?",
      textConfirm: "Yes, Cancel",
      textCancel: "No, Keep it",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF4C734D),
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back();
        controller.cancelMyPlan();
      },
    );
  }

  // Original Plan Card (Stylized)
  Widget _buildPlanCard(dynamic plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4C734D).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '${plan.price} ${plan.currency}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4C734D),
            ),
          ),
          Text(
            'for ${plan.durationDays} days',
            style: const TextStyle(color: Colors.grey),
          ),
          if (plan.description.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Text(plan.description, style: TextStyle(color: Colors.grey[700])),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  (controller.isLoading.value ||
                      controller.isCheckoutInProgress.value ||
                      controller.isActivationPending.value)
                  ? null
                  : () => controller.subscribe(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C734D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                controller.isCheckoutInProgress.value
                    ? 'Processing...'
                    : controller.isActivationPending.value
                    ? 'Activating...'
                    : 'Subscribe Now',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
