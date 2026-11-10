import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class WebSignUpView extends GetView<AuthController> {
  WebSignUpView({super.key});

  final userCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Row(
            children: [
              if (isWide) const Expanded(child: _BrandPanel()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 530),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Join Mission For Nation Ministry',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 36),
                          _label('USERNAME'),
                          _field(
                            controller: userCtrl,
                            hint: 'e.g. John Doe',
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 18),
                          _label('EMAIL ADDRESS'),
                          _field(
                            controller: emailCtrl,
                            hint: 'yourname@example.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 18),
                          _label('PHONE NUMBER'),
                          _field(
                            controller: phoneCtrl,
                            hint: '9xxxxxxxx',
                            icon: Icons.phone_android_outlined,
                            prefixText: '+251  ',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _label('PASSWORD'),
                          Obx(
                            () => _field(
                              controller: passCtrl,
                              hint: 'At least 6 characters',
                              icon: Icons.lock_outline,
                              obscureText: obscurePassword.value,
                              textInputAction: TextInputAction.next,
                              suffixIcon: _visibilityButton(
                                obscurePassword,
                                'password',
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _label('CONFIRM PASSWORD'),
                          Obx(
                            () => _field(
                              controller: confirmPassCtrl,
                              hint: 'Re-enter your password',
                              icon: Icons.lock_outline,
                              obscureText: obscureConfirmPassword.value,
                              textInputAction: TextInputAction.done,
                              suffixIcon: _visibilityButton(
                                obscureConfirmPassword,
                                'confirmed password',
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  disabledBackgroundColor: const Color(
                                    0xFFD4AF37,
                                  ),
                                  disabledForegroundColor: Colors.black,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                        'Create Account',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Center(
                            child: TextButton(
                              onPressed: () => Get.toNamed(Routes.SIGN_IN),
                              child: const Text(
                                'Already have an account? Sign In',
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
              ),
            ],
          );
        },
      ),
    );
  }

  void _submit() {
    controller.signUp(
      userCtrl.text,
      emailCtrl.text,
      passCtrl.text,
      confirmPassCtrl.text,
      phoneCtrl.text,
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _visibilityButton(RxBool obscured, String fieldName) => IconButton(
    tooltip: obscured.value ? 'Show $fieldName' : 'Hide $fieldName',
    onPressed: obscured.toggle,
    icon: Icon(
      obscured.value
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
      color: Colors.white54,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? prefixText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        prefix: prefixText == null
            ? null
            : Text(
                prefixText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF16161A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
          radius: 0.8,
        ),
      ),
      child: Column(
        children: [
          const Spacer(),
          Image.asset('assets/images/MissionForNation.png', height: 180),
          const SizedBox(height: 30),
          const Text(
            'Mission For Nation',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const Text(
            'MINISTRY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 4,
            ),
          ),
          const Spacer(),
          const Text(
            '"Go therefore and make disciples of all nations"\n— Matthew 28:19',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
