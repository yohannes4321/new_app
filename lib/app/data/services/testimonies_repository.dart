import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/testimony_model.dart';
import 'auth_service.dart';

class TestimoniesRepository extends GetConnect {
  final _auth = Get.find<AuthService>();

  String? _resolveCurrentUserUid() {
    final profile = _auth.userProfile;
    final profileUid =
        profile['firebaseUid']?.toString() ?? profile['uid']?.toString();
    if (profileUid != null && profileUid.isNotEmpty) {
      return profileUid;
    }
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void onInit() {
    httpClient.baseUrl = "https://church-backend-s1rb.onrender.com/api";
    super.onInit();
  }

  Future<List<TestimonyModel>> getTestimonies({int page = 1}) async {
    final response = await get(
      "/testimonies?page=$page&limit=10",
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
    );

    if (response.status.isOk) {
      final String? myUid = _resolveCurrentUserUid();
      final List data = response.body['data'] ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => TestimonyModel.fromJson(e, myUid))
          .toList();
    }
    return [];
  }

  // ✅ FIXED: Explicitly pass the action (Like or Unlike)
  Future<bool> toggleLike(String id, bool isCurrentlyLiked) async {
    // If it WAS liked, we call DELETE (unlike). If it WAS NOT liked, we call POST (like).
    final Response res = isCurrentlyLiked
        ? await delete(
            "/testimonies/$id/like",
            headers: {
              'Authorization': 'Bearer ${_auth.authToken}',
              'Content-Type': 'application/json',
            },
          )
        : await post(
            "/testimonies/$id/like",
            {},
            headers: {
              'Authorization': 'Bearer ${_auth.authToken}',
              'Content-Type': 'application/json',
            },
          );

    // 409 usually means "Already Liked" or "Already Unliked", treat as success
    if (res.statusCode == 409) return true;

    if (!res.status.isOk) {
      print(
        "❌ LIKE TOGGLE FAILED | id=$id | wasLiked=$isCurrentlyLiked | status=${res.statusCode} | body=${res.body}",
      );
    }

    return res.status.isOk;
  }

  // POST /api/testimonies/:id/comment
  Future<bool> addComment(String id, String text) async {
    final res = await post(
      "/testimonies/$id/comment",
      {"text": text},
      headers: {'Authorization': 'Bearer ${_auth.authToken}'},
      contentType: 'application/json',
    );

    if (!res.status.isOk) {
      print(
        "❌ COMMENT FAILED | id=$id | status=${res.statusCode} | body=${res.body}",
      );
    }
    return res.status.isOk;
  }
}
