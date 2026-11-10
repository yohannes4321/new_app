import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SignUpView extends GetView<AuthController> {
  SignUpView({super.key});

  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final Color primaryGreen = const Color(0xFF4C734D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/MissionForNation.png',
                    height: 100,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Mission For Nation",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  Text(
                    "CREATE YOUR ACCOUNT",
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

            const SizedBox(height: 50),

            _inputLabel("Full Name"),
            TextField(
              controller: userCtrl,
              decoration: _inputDecoration(
                "Enter your name",
                Icons.person_outline,
              ),
            ),

            const SizedBox(height: 20),

            _inputLabel("Email Address"),
            TextField(
              controller: emailCtrl,
              decoration: _inputDecoration(
                "Enter your email",
                Icons.mail_outline,
              ),
            ),

            const SizedBox(height: 20),

            _inputLabel("Phone Number"),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: _inputDecoration(
                "9xxxxxxxx",
                Icons.phone_android_outlined,
                prefixText: '+251  ',
              ),
            ),

            const SizedBox(height: 20),

            _inputLabel("Password"),
            Obx(
              () => TextField(
                controller: passCtrl,
                obscureText: obscurePassword.value,
                decoration: _inputDecoration(
                  "At least 6 characters",
                  Icons.lock_outline,
                  suffixIcon: IconButton(
                    tooltip: obscurePassword.value
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: obscurePassword.toggle,
                    icon: Icon(
                      obscurePassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _inputLabel("Confirm Password"),
            Obx(
              () => TextField(
                controller: confirmPassCtrl,
                obscureText: obscureConfirmPassword.value,
                decoration: _inputDecoration(
                  "Re-enter your password",
                  Icons.lock_outline,
                  suffixIcon: IconButton(
                    tooltip: obscureConfirmPassword.value
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: obscureConfirmPassword.toggle,
                    icon: Icon(
                      obscureConfirmPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Obx(
              () => Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    disabledBackgroundColor: primaryGreen,
                    disabledForegroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.signUp(
                          userCtrl.text,
                          emailCtrl.text,
                          passCtrl.text,
                          confirmPassCtrl.text,
                          phoneCtrl.text,
                        ),
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
                          "Create Account",
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
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    ),
  );

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
    String? prefixText,
  }) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: Colors.grey, size: 20),
    prefix: prefixText == null
        ? null
        : Text(
            prefixText,
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
          ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.grey[50],
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[200]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryGreen, width: 1.5),
    ),
  );
}
