import 'dart:async';
import 'package:get/get.dart';

class OtpVerifiedController extends GetxController {
  String otp = "";
  String email = "";
  bool isFromForgotScreen = true;
  bool isFill = false;
  String otpVal= '';
  int secondsRemaining = 30;
  bool enableResend = false;
  Timer? timer;

  String emailId = '';

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  @override
  void onInit() {
    super.onInit();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
          secondsRemaining--;
        update();
      } else {
          enableResend = true;
       update();
      }
    });

    if(Get.arguments!=null){
      emailId = Get.arguments['email'];
    }
  }
  void resendCode() {
    secondsRemaining = 30;
    enableResend = false;
    update();
  }


  @override
  void onClose() {
    super.onClose();
  }
}
