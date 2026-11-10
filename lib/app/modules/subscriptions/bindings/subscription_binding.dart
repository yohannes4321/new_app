import 'package:get/get.dart';
import '../controllers/subscriptions_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionsController>(() => SubscriptionsController());
  }
}
