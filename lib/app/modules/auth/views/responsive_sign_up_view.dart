import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'sign_up_view.dart';
import 'web_sign_up_view.dart';

class ResponsiveSignUpView extends StatelessWidget {
  const ResponsiveSignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? WebSignUpView() : SignUpView();
  }
}
