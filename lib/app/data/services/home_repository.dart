import 'package:get/get.dart';

import '../api_constants.dart';
import '../models/live_stream_model.dart';

class HomeRepository extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    super.onInit();
  }

  Future<LiveStreamModel> getLiveStream() async {
    final response = await get(ApiConstants.liveEndpoint);

    if (!response.status.isOk || response.body == null) {
      throw Exception('Failed to fetch live stream: ${response.statusCode}');
    }

    final body = response.body;
    final payload = body is Map && body['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(body['data'] as Map<String, dynamic>)
        : Map<String, dynamic>.from(body as Map);

    return LiveStreamModel.fromJson(payload);
  }

  Future<List<Map<String, dynamic>>> getTestimonies() async {
    return [];
  }
}
