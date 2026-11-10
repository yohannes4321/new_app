import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/profile_repository.dart';
import '../../../data/models/event_registration_model.dart';

class ProfileController extends GetxController {
  final repository = Get.find<ProfileRepository>();
  final authService = Get.find<AuthService>();

  var isLoading = true.obs;

  // Profile Data
  var username = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var profileImage = "".obs;

  // Stats Data
  var totalDonations = 0.0.obs;
  var eventsRegistered = 0.obs;
  var isPremium = false.obs;
  var isUploadingImage = false.obs;
  var eventHistory = <EventRegistrationModel>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  void fetchProfileData() async {
    isLoading(true);
    try {
      // 1. Load basic info from the local cache first so UI doesn't look empty
      final cachedProfile = authService.userProfile;
      username.value = cachedProfile['username'] ?? "Church Member";
      email.value =
          cachedProfile['email'] ??
          FirebaseAuth.instance.currentUser?.email ??
          "";

      // 2. Fetch fresh data from backend
      final profileDetails = await repository.getProfileDetails();
      final profileStats = await repository.getProfileStats();
      final myEvents = await repository.getMyEventHistory();

      // 3. Update Observables
      if (profileDetails != null) {
        username.value = profileDetails['username'] ?? username.value;
        phone.value = profileDetails['phone_number'] ?? "No phone added";
        profileImage.value = profileDetails['profile_image'] ?? "";
        _syncCachedProfile(profileDetails);
      }

      if (profileStats != null) {
        totalDonations.value = (profileStats['total_donations'] ?? 0)
            .toDouble();
        eventsRegistered.value = profileStats['events_registered'] ?? 0;
        isPremium.value = profileStats['is_premium'] ?? false;

        // Keep global auth state synced with the latest premium status
        _syncCachedProfile({'is_premium': isPremium.value});
      }

      eventHistory.assignAll(myEvents);
      eventHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Keep joined count in sync even when stats lags behind.
      if (eventHistory.isNotEmpty) {
        eventsRegistered.value = eventHistory.length;
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickAndUploadProfileImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      isUploadingImage(true);
      final updatedProfile = await repository.uploadProfileImage(
        File(picked.path),
      );

      if (updatedProfile == null) {
        Get.snackbar('Upload Failed', 'Could not update profile picture.');
        return;
      }

      profileImage.value = (updatedProfile['profile_image'] ?? '').toString();
      _syncCachedProfile(updatedProfile);
      Get.snackbar('Success', 'Profile picture updated successfully.');
    } catch (_) {
      Get.snackbar('Error', 'Could not update profile picture.');
    } finally {
      isUploadingImage(false);
    }
  }

  void _syncCachedProfile(Map<String, dynamic> updates) {
    final merged = Map<String, dynamic>.from(authService.userProfile);
    merged.addAll(updates);
    authService.setUser(merged);
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    authService.logout(); // Clears token and storage
    Get.offAllNamed(Routes.SIGN_IN); // Send back to login screen
  }
}
