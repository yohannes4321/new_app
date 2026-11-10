import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:church_app/app/widgets/main_bottom_nav.dart';
import '../../../../routes/app_routes.dart';
import '../payment_history_controller.dart';

class PaymentHistoryView extends GetView<PaymentHistoryController> {
  const PaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MainBottomNav.backOrHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        bottomNavigationBar: const MainBottomNav(activeRoute: Routes.PROFILE),
        appBar: AppBar(
          title: const Text(
            "History",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: MainBottomNav.backOrHome,
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4C734D)),
            );
          }

          if (controller.purchases.isEmpty && controller.donations.isEmpty) {
            return const Center(child: Text("No transactions found."));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (controller.purchases.isNotEmpty) ...[
                _sectionHeader("Book Purchases"),
                ...controller.purchases.map((p) => _buildPurchaseCard(p)),
              ],
              const SizedBox(height: 24),
              if (controller.donations.isNotEmpty) ...[
                _sectionHeader("Ministry Gifts"),
                ...controller.donations.map((d) => _buildDonationCard(d)),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _buildPurchaseCard(dynamic purchase) {
    return _baseCard(
      title: purchase.bookTitle,
      subtitle: DateFormat('MMM dd, yyyy').format(purchase.date),
      trailing: "${purchase.amount} ETB",
      icon: Icons.menu_book_rounded,
      color: Colors.blue,
    );
  }

  Widget _buildDonationCard(dynamic donation) {
    return _baseCard(
      title: "Ministry Donation",
      subtitle: DateFormat('MMM dd, yyyy').format(donation.date),
      trailing: "${donation.amount} ${donation.currency}",
      icon: Icons.favorite_rounded,
      color: Colors.pinkAccent,
    );
  }

  Widget _baseCard({
    required String title,
    required String subtitle,
    required String trailing,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF4C734D),
            ),
          ),
        ],
      ),
    );
  }
}
