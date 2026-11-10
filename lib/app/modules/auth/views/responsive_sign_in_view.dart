import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'sign_in_view.dart';
import 'web_sign_in_view.dart';

class ResponsiveSignInView extends StatelessWidget {
  const ResponsiveSignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? WebSignInView() : SignInView();
  }
}
