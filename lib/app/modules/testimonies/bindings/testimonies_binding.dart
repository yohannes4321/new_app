import 'package:get/get.dart';
import '../controllers/testimonies_controller.dart';

class TestimoniesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestimoniesController>(() => TestimoniesController());
  }
}
