import 'package:get/get.dart';
import '../controllers/donation_controller.dart';
import '../../../data/services/donations_repository.dart';

class DonationBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Inject the Repository (The part that talks to the API)
    // We use lazyPut so it only consumes memory when the user opens the Give page
    Get.lazyPut<DonationsRepository>(() => DonationsRepository());

    // 2. Inject the Controller (The logic/UI manager)
    Get.lazyPut<DonationController>(() => DonationController());
  }
}