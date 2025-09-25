import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/accept_invite_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/create_company_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/landing_screen_controller.dart';
import 'package:get/get.dart';

import '../../../../Home/Presentation/Controller/company_service.dart';
import '../Presentation/Controllers/login_controller.dart';
import '../Presentation/Controllers/verify_otp_controller.dart';

class AcceptInviteBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AcceptInviteController>(AcceptInviteController());
  }
}

class CreateCompanyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateCompanyController>(CreateCompanyController());
  }
}

class LandingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LandingScreenController>(LandingScreenController());
  }
}


class LoginGBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginGController>(LoginGController());
  }
}
class VerifyOTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<VerifyOtpController>(VerifyOtpController());
  }
}
