// lib/app/modules/sermon/bindings/sermons_binding.dart
import 'package:get/get.dart';
import '../../../data/services/sermons_repository.dart';
import '../controllers/sermons_controller.dart';

class SermonsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SermonsRepository>()) {
      Get.lazyPut<SermonsRepository>(() => SermonsRepository());
    }
    Get.lazyPut<SermonsController>(() => SermonsController());
  }
}
