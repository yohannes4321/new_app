import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/sermon_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/sermons_repository.dart';
import '../../../data/services/subscription_repository.dart';

class SermonsController extends GetxController {
  final repository = Get.find<SermonsRepository>();
  final authService = Get.find<AuthService>();
  final subscriptionRepository = Get.find<SubscriptionRepository>();

  var isLoading = true.obs;
  var gateLoading = false.obs;
  var categories = <Map<String, dynamic>>[].obs;
  var sermons = <SermonModel>[].obs;

  var selectedCategoryKey = "".obs;
  var selectedCategoryApiId = "".obs;
  var selectedCategoryName = "".obs;
  var selectedCategoryIndex = (-1).obs;
  final searchQuery = "".obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // 🔥 ROBUST ID EXTRACTION: Backend uses _id for MongoDB
  String getCategoryApiId(Map<String, dynamic> category) {
    final rawId = category['_id'] ?? category['id'];
    final id = rawId?.toString().trim() ?? '';
    return id;
  }

  String getCategoryName(Map<String, dynamic> category) {
    return (category['name'] ?? 'Untitled').toString();
  }

  String getCategoryKey(Map<String, dynamic> category) {
    final apiId = getCategoryApiId(category);
    if (apiId.isNotEmpty) {
      return apiId;
    }
    return getCategoryName(category).trim().toLowerCase();
  }

  List<Map<String, dynamic>> _dedupeCategoriesByName(
    List<Map<String, dynamic>> source,
  ) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final cat in source) {
      final name = getCategoryName(cat).trim().toLowerCase();
      if (name.isEmpty) continue;
      if (seen.contains(name)) continue;
      seen.add(name);
      result.add(cat);
    }

    return result;
  }

  void filterSermons(String query) {
    searchQuery.value = query;
  }

  void loadInitialData() async {
    isLoading(true);
    try {
      final List<Map<String, dynamic>> catList = await repository
          .getCategories();

      // 🔥 PHASE 1: Add a manual "All" category at the start
      final List<Map<String, dynamic>> combinedCategories = [
        {"_id": "all", "name": "All"},
        ..._dedupeCategoriesByName(catList),
      ];

      categories.assignAll(combinedCategories);

      // 🔥 PHASE 2: Default to "All"
      if (categories.isNotEmpty) {
        selectCategoryAt(0, isInitial: true);
      }
    } finally {
      isLoading(false);
    }
  }

  // Deterministic selection: UI highlight follows tapped index, fetch follows category id.
  void selectCategoryAt(int index, {bool isInitial = false}) {
    if (index < 0 || index >= categories.length) return;

    if (!isInitial && selectedCategoryIndex.value == index) return;

    final category = categories[index];
    final String apiId = getCategoryApiId(category);
    final String categoryKey = getCategoryKey(category);

    selectedCategoryIndex.value = index;

    selectedCategoryApiId.value = apiId;
    selectedCategoryKey.value = categoryKey;
    selectedCategoryName.value = getCategoryName(category);

    fetchSermons();
  }

  void fetchSermons() async {
    if (selectedCategoryApiId.value.isEmpty) {
      sermons.clear();
      Get.snackbar(
        "Category Error",
        "This category has no valid ID. Please fix category data in backend.",
      );
      return;
    }

    isLoading(true);

    try {
      final list = await repository.getSermonsByCategory(
        selectedCategoryApiId.value,
      );

      if (list.isEmpty && sermons.isNotEmpty) {
        Get.snackbar(
          "No Sermons",
          "No sermons found for ${selectedCategoryName.value} right now.",
        );
      }

      sermons.assignAll(list);
    } catch (e) {
      Get.snackbar("Error", "Could not fetch sermons for this category.");
    } finally {
      isLoading(false);
    }
  }

  List<SermonModel> get filteredSermons {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return sermons;
    return sermons.where((s) => s.title.toLowerCase().contains(query)).toList();
  }

  Future<void> onSermonTap(SermonModel sermon) async {
    if (!sermon.isPremium) {
      Get.toNamed(Routes.SERMON_DETAILS, arguments: sermon);
      return;
    }

    gateLoading(true);
    try {
      final active = await subscriptionRepository.hasActiveSubscription();
      final updated = Map<String, dynamic>.from(authService.userProfile);
      updated['is_premium'] = active;
      authService.setUser(updated);

      if (!active) {
        Get.toNamed(Routes.SUBSCRIPTIONS);
        return;
      }

      Get.toNamed(Routes.SERMON_DETAILS, arguments: sermon);
    } catch (_) {
      Get.snackbar(
        'Subscription Check Failed',
        'Unable to verify premium status. Please try again.',
      );
    } finally {
      gateLoading(false);
    }
  }
}
