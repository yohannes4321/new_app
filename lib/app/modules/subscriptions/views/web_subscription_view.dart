import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/subscriptions_controller.dart';

class WebSubscriptionView extends GetView<SubscriptionsController> {
  const WebSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = context.width;
    final bool isSmallScreen = width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF121216),
      drawer: isSmallScreen ? Drawer(child: _buildSidebar(context)) : null,
      body: Row(
        children: [
          if (!isSmallScreen) _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildWebHeader(context, isSmallScreen),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: Obx(() {
                        if (controller.isLoading.value &&
                            controller.plans.isEmpty &&
                            !controller.isAlreadyPremium.value) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: CircularProgressIndicator(
                              color: Color(0xFFD4AF37),
                            ),
                          );
                        }

                        if (controller.isAlreadyPremium.value) {
                          return _buildManageSubscriptionPanel();
                        }

                        return Column(
                          children: [
                            const Text(
                              "Choose Your Plan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Unlock unlimited access to all archived sermons and teachings",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 60),
                            if (controller.plans.isEmpty)
                              const Text(
                                'No active plans found.',
                                style: TextStyle(color: Colors.white70),
                              )
                            else
                              Wrap(
                                spacing: 30,
                                runSpacing: 30,
                                alignment: WrapAlignment.center,
                                children: controller.plans
                                    .map((plan) => _buildWebPlanCard(plan))
                                    .toList(),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSubscriptionPanel() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.workspace_premium,
              color: Color(0xFFD4AF37),
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'You are a Premium Member!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your premium access is active. You can cancel anytime from here.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : _showCancelDialog,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  foregroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel Subscription'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    Get.defaultDialog(
      title: 'Cancel Subscription?',
      middleText: 'Are you sure you want to stop your premium subscription?',
      textConfirm: 'Yes, Cancel',
      textCancel: 'Keep Premium',
      confirmTextColor: Colors.black,
      buttonColor: const Color(0xFFD4AF37),
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back();
        controller.cancelMyPlan();
      },
    );
  }

  Widget _buildWebHeader(BuildContext context, bool isSmallScreen) {
    final authService = Get.find<AuthService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          if (isSmallScreen)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          const Expanded(
            child: Text(
              'Premium Membership',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() {
            final loggedIn = authService.isLoggedIn.value;

            if (!isSmallScreen) {
              return Row(
                children: [
                  if (!loggedIn)
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.SIGN_UP),
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (loggedIn) {
                        Get.toNamed(Routes.PROFILE);
                      } else {
                        Get.toNamed(Routes.SIGN_IN);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: loggedIn
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFF1A73E8),
                    ),
                    child: Text(
                      loggedIn ? 'Profile' : 'Login',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            }

            return IconButton(
              icon: Icon(
                loggedIn ? Icons.person : Icons.login,
                color: Colors.white,
              ),
              onPressed: () {
                loggedIn
                    ? Get.toNamed(Routes.PROFILE)
                    : Get.toNamed(Routes.SIGN_IN);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF18181C),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset('assets/images/MissionForNation.png', height: 80),
          const SizedBox(height: 10),
          const Text(
            'Mission For Nation',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          _sidebarItem(
            Icons.home_filled,
            'Home',
            false,
            () => _goToWebRoute(Routes.HOME),
          ),
          _sidebarItem(
            Icons.workspace_premium,
            'Manage Subscription',
            true,
            () {},
          ),
        ],
      ),
    );
  }

  void _goToWebRoute(String route) {
    if (Get.currentRoute == route) return;
    Get.offNamed(route);
  }

  Widget _sidebarItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPlanCard(dynamic plan) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            plan.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "${plan.price} ETB",
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            "/ ${plan.durationDays} days",
            style: const TextStyle(color: Colors.white38),
          ),
          const Divider(height: 60, color: Colors.white10),
          Text(
            plan.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => controller.subscribe(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Subscribe Now",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
