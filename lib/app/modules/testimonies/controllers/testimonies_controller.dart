import 'package:get/get.dart';
import '../../../data/models/testimony_model.dart';
import '../../../data/services/testimonies_repository.dart';

class TestimoniesController extends GetxController {
  final repository = Get.find<TestimoniesRepository>();
  var isLoading = true.obs;
  var testimonies = <TestimonyModel>[].obs;
  final _likeSyncingIds = <String>{}.obs;

  int _weightedSort(TestimonyModel a, TestimonyModel b) {
    final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    final byNewest = bCreated.compareTo(aCreated);
    if (byNewest != 0) return byNewest;

    final byLikes = b.likeCount.compareTo(a.likeCount);
    if (byLikes != 0) return byLikes;

    final byComments = b.commentCount.compareTo(a.commentCount);
    if (byComments != 0) return byComments;

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  @override
  void onInit() {
    super.onInit();
    fetchTestimonies();
  }

  void fetchTestimonies() async {
    isLoading(true);
    try {
      final items = await repository.getTestimonies();
      items.sort(_weightedSort);
      testimonies.assignAll(items);
    } finally {
      isLoading(false);
    }
  }

  // Social Logic: Toggle Like
  void toggleLike(int index) async {
    final item = testimonies[index];
    if (_likeSyncingIds.contains(item.id)) return;

    // 🔥 STORE THE ORIGINAL STATE BEFORE WE FLIP IT
    final bool wasLikedBeforeTap = item.isLiked;

    _likeSyncingIds.add(item.id);

    // 1. Optimistic Update (UI updates immediately)
    item.isLiked = !wasLikedBeforeTap;
    item.likeCount += item.isLiked ? 1 : -1;
    if (item.likeCount < 0) item.likeCount = 0;

    testimonies.refresh();

    // 2. Background Server Sync
    // We pass 'wasLikedBeforeTap' so the repo knows if it should POST or DELETE
    final success = await repository.toggleLike(item.id, wasLikedBeforeTap);

    if (!success) {
      // Revert only if server actually fails
      item.isLiked = wasLikedBeforeTap;
      item.likeCount += item.isLiked ? 1 : -1;
      if (item.likeCount < 0) item.likeCount = 0;
      testimonies.refresh();
      Get.snackbar("Sync Error", "Could not update like status.");
    }

    _likeSyncingIds.remove(item.id);
  }

  void addComment(String testimonyId, String text) async {
    if (text.trim().isEmpty) return;

    isLoading(true);
    final success = await repository.addComment(testimonyId, text);

    if (success) {
      fetchTestimonies();
      Get.back();
      Get.snackbar("Success", "Comment posted!");
    } else {
      Get.snackbar("Error", "Could not post comment.");
    }
    isLoading(false);
  }
}
