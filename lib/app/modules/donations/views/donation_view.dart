import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:church_app/app/widgets/main_bottom_nav.dart';
import '../controllers/donation_controller.dart';

class DonationView extends GetView<DonationController> {
  const DonationView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF4C734D); // Your ministry green

    return WillPopScope(
      onWillPop: () async {
        MainBottomNav.backOrHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: MainBottomNav.backOrHome,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // --- HERO SECTION WITH LOGO ---
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/MissionForNation.png',
                      height: 100,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/event_placeholder.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Mission For Nation",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: primaryGreen,
                      ),
                    ),
                    Text(
                      "SUPPORT OUR MINISTRY",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SELECT GIFT AMOUNT",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- FIXED GRID (Fixes the Assertion Error) ---
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true, // Crucial for being inside a ScrollView
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [100, 500, 1000, 5000].map((amt) {
                        return Obx(() {
                          bool isSelected =
                              controller.selectedAmount.value == amt;
                          return InkWell(
                            onTap: () => controller.selectAmount(amt),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryGreen
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryGreen
                                      : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "$amt ETB",
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    _inputLabel("Custom Amount"),
                    TextField(
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        "Enter amount",
                        Icons.attach_money,
                      ),
                    ),

                    const SizedBox(height: 20),
                    _inputLabel("Note / Purpose"),
                    TextField(
                      controller: controller.messageController,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        "ለወንጌል ስርጭት ስጦታ",
                        Icons.edit_note,
                        alignTop: true,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- SECURE BUTTON ---
                    Obx(
                      () => Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: primaryGreen.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.startDonation(),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Give Securely",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "Powered by Chapa Gateway",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
  );

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    bool alignTop = false,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
    prefixIcon: alignTop
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Icon(icon, color: Colors.grey, size: 20),
            ],
          )
        : Icon(icon, color: Colors.grey, size: 20),
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: const EdgeInsets.symmetric(vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[200]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4C734D), width: 1.5),
    ),
  );
}
