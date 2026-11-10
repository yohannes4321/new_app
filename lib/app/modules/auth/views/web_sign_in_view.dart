import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class WebSignInView extends GetView<AuthController> {
  WebSignInView({super.key});

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Deep black background
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 900;
          return Row(
            children: [
              // --- LEFT SIDE: BRAND IDENTITY (Hidden on mobile web) ---
              if (isWide)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
                        center: Alignment.center,
                        radius: 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // Logo
                        Image.asset(
                          'assets/images/MissionForNation.png',
                          height: 180,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Mission For Nation",
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Text(
                          "MINISTRY",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            letterSpacing: 4,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "\"Go therefore and make disciples of all nations\"\n— Matthew 28:19",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white24,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

              // --- RIGHT SIDE: LOGIN FORM ---
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome back",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Sign in to your account portal",
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                        const SizedBox(height: 40),

                        _webInputLabel("EMAIL ADDRESS"),
                        _webTextField(
                          emailCtrl,
                          "admin@church.com",
                          Icons.mail_outline,
                        ),
                        const SizedBox(height: 20),

                        _webInputLabel("PASSWORD"),
                        _webTextField(
                          passCtrl,
                          "••••••••",
                          Icons.lock_outline,
                          isPass: true,
                        ),

                        const SizedBox(height: 40),

                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.signIn(
                                      emailCtrl.text.trim(),
                                      passCtrl.text,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFD4AF37,
                                ), // Gold button
                                disabledBackgroundColor: const Color(
                                  0xFFD4AF37,
                                ),
                                disabledForegroundColor: Colors.black,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 10,
                                shadowColor: const Color(
                                  0xFFD4AF37,
                                ).withOpacity(0.3),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        Center(
                          child: TextButton(
                            onPressed: () => Get.toNamed(Routes.SIGN_UP),
                            child: const Text(
                              "Create a new account",
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _webInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _webTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPass = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white12),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
