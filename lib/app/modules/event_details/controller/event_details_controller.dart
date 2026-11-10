import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:church_app/app/widgets/app_feedback.dart';
import '../../events/controllers/events_controller.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/events_repository.dart';
import '../../../routes/app_routes.dart';

class EventDetailsController extends GetxController {
  final _repo = Get.find<EventsRepository>();
  EventModel? event;

  var isRegistered = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    if (Get.arguments is EventModel) {
      event = Get.arguments;
      // Check the server for real status instead of relying only on model cache.
      await _syncRegistrationStatus();
    }
  }

  Future<void> _syncRegistrationStatus() async {
    if (event == null) return;
    isLoading(true);
    try {
      final joinedIds = await _repo.getMyJoinedEventIds();
      isRegistered.value = joinedIds.contains(event!.id);
      event!.isUserRegistered = isRegistered.value;
    } catch (e) {
      print("Sync failed: $e");
    } finally {
      isLoading(false);
    }
  }

  // REAL LOGIC: Join/Cancel Registration via API
  void toggleRegistration() async {
    if (event == null) return;

    final auth = Get.find<AuthService>();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || auth.authToken.isEmpty) {
      showAppFeedback(
        'Sign In Required',
        'Please sign in to manage event registration.',
        type: AppFeedbackType.warning,
      );
      Get.toNamed(Routes.SIGN_IN);
      return;
    }

    await firebaseUser.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (refreshedUser?.emailVerified != true) {
      showAppFeedback(
        'Verify Email',
        'Please verify your email before registering for events.',
        type: AppFeedbackType.warning,
      );
      Get.toNamed(Routes.VERIFY_EMAIL);
      return;
    }

    isLoading(true);

    // Determine if we are joining or cancelling
    final bool shouldRegister = !isRegistered.value;
    bool success = false;

    if (shouldRegister) {
      success = await _repo.register(event!.id);
    } else {
      success = await _repo.unregister(event!.id);
    }

    if (success) {
      isRegistered.value = shouldRegister;
      event!.isUserRegistered = shouldRegister;

      // Crucial: refresh the list so Home/Events sees latest status immediately
      if (Get.isRegistered<EventsController>()) {
        Get.find<EventsController>().fetchEvents();
      }

      Get.snackbar("Success", shouldRegister ? "Joined!" : "Unregistered");
    } else {
      Get.snackbar("Error", "Could not process request.");
    }
    isLoading(false);
  }

  String get formattedFullDate {
    if (event == null) return "";
    return "${event!.month} ${event!.day}, ${event!.dateTime.year} at ${event!.dateTime.hour}:00";
  }
}
