// lib/app/modules/events/bindings/events_binding.dart
import 'package:get/get.dart';
import '../controllers/events_controller.dart';

class EventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventsController>(() => EventsController());
  }
}
