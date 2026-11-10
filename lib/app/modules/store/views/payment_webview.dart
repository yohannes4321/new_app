import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final String url = Get.arguments;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final lower = request.url.toLowerCase();

            // 🔥 THE FIX: We MUST NOT intercept generic "success" or "google.com" because 
            // Chapa's own checkout URL might temporarily contain "success". If we close
            // the webview too early, Chapa never redirects to the backend's /verify 
            // endpoint, and the user's subscription is never activated in the database!
            
            final isSuccess =
                lower.contains("subscription-success") || // Deployed Subscription Verify Return
                lower.contains("payment+success") ||      // Deployed Book Verify Return (Google)
                lower.contains("payment-success");        // Local Book Verify Return

            if (isSuccess) {
              Get.back(result: true); // Close and return 'true' to refresh
              return NavigationDecision.prevent;
            }

            final isFailure =
                lower.contains("subscription-failed") ||
                lower.contains("payment+failed") ||
                lower.contains("payment-failed");

            if (isFailure) {
              Get.back(result: false);
              return NavigationDecision.prevent;
            }

            // Let Chapa navigate normally, including reaching the backend /verify endpoint
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Payment"),
        backgroundColor: const Color(0xFF4C734D),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
