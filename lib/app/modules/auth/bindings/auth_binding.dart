import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // This injects the logic into the app
    Get.lazyPut<AuthController>(() => AuthController());
  }
}