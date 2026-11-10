import 'package:get/get.dart';
import 'auth_service.dart';
import '../api_constants.dart';

class DonationsRepository extends GetConnect {
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    super.onInit();
  }

  Future<String> initializeDonation(Map<String, dynamic> data) async {
    final response = await post(
      "/donations/initialize",
      data,
      headers: {
        'Authorization': 'Bearer ${_auth.authToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.status.isOk) {
      final body = response.body;
      final dynamic checkoutUrl =
          body?['checkoutUrl'] ??
          body?['checkout_url'] ??
          body?['data']?['checkoutUrl'] ??
          body?['data']?['checkout_url'] ??
          '';
      if (checkoutUrl is! String || checkoutUrl.isEmpty) {
        throw Exception('Payment URL is missing from server response.');
      }
      return checkoutUrl;
    } else {
      final message =
          response.body?['message'] ??
          response.body?['error'] ??
          response.statusText ??
          "Failed to start donation.";
      throw Exception(
        'Donation init failed (${response.statusCode ?? 'unknown'}): ${message.toString()}',
      );
    }
  }
}
