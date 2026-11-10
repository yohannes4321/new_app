import 'package:get/get.dart';
import '../models/sermon_model.dart';
import 'auth_service.dart';

class SermonsRepository extends GetConnect {
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    httpClient.baseUrl = "https://church-backend-s1rb.onrender.com/api";
    super.onInit();
  }

  // GET /api/sermons/categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await get(
      "/sermons/categories",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );
    if (res.isOk) {
      return List<Map<String, dynamic>>.from(res.body['data'] ?? []);
    }
    return [];
  }

  // GET /api/sermons/all OR /api/sermons?categoryId=...
  Future<List<SermonModel>> getSermonsByCategory(String categoryId) async {
    // For "All", use the dedicated endpoint requested by backend.
    final String endpoint = (categoryId == "all")
        ? "/sermons/all"
        : "/sermons?categoryId=$categoryId";

    final res = await get(
      endpoint,
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );

    if (res.isOk) {
      final List data = res.body['data'] ?? [];
      return data.map((e) => SermonModel.fromJson(e)).toList();
    }
    return [];
  }
}
