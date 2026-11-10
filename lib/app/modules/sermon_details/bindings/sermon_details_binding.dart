// lib/app/modules/sermon_details/bindings/sermon_details_binding.dart
import 'package:get/get.dart';
import '../controllers/sermon_details_controller.dart';

class SermonDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SermonDetailsController>(() => SermonDetailsController());
  }
}
