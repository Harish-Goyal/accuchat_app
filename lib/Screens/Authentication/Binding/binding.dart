import 'package:get/get.dart';
import '../Presentation/controller/change_password_controler.dart';
import '../Presentation/controller/loginController.dart';
import '../Presentation/controller/otp_verfied_controller.dart';

class AuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(LoginController());
    // Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<OtpVerifiedController>(() => OtpVerifiedController());
  }
}

class ChangePassBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChangePassController>(() => ChangePassController());
  }
}



