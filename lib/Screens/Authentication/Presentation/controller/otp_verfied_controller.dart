import 'dart:async';
import 'package:get/get.dart';
// import 'package:otp_text_field/otp_field.dart';

class OtpVerifiedController extends GetxController {
  // late OtpFieldController otpFieldController;
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
    // otpFieldController = OtpFieldController();
    // isFromForgotScreen = Get.arguments[RoutesArgument.isFromForgotScreen];
    // email = Get.arguments[RoutesArgument.emailKey];
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

  // hitOtpAPI({otp}) {
  //   customLoader.show();
  //   FocusManager.instance.primaryFocus!.unfocus();
  //   Map<String,dynamic> data = {
  //     "otp_number": otp,
  //     "email_id": emailId
  //   };
  //   Get.find<AuthApiServiceImpl>().sendOtpApiCall(dataBody: data, secretKey: storage.read(user_key)).then((value) async {
  //     customLoader.hide();
  //     toast(value.message);
  //     if(value.statusCode==200) {
  //       Get.toNamed(AppRoutes.resetPassword, arguments: {'email': emailId});
  //     }
  //   }).onError((error, stackTrace) {
  //     customLoader.hide();
  //     toast(error);
  //   }
  //   );
  // }
  //
  // hitApiToResentOtpPass(){
  //   customLoader.show();
  //   Map<String,dynamic>  data= {
  //     "email_id":emailId
  //   };
  //   Get.find<AuthApiServiceImpl>().forgotPassApiCall(secretKey: storage.read(user_key),dataBody: data).then((value) {
  //     customLoader.hide();
  //     // successModel=value;
  //     toast(value.optNumber.toString()??'');
  //     update();
  //   }).onError((error, stackTrace) {
  //     customLoader.hide();
  //     toast(error.toString());
  //   });
  // }
  //
  // hitResendOtpAPI() {
  //   customLoader.show();
  //   FocusManager.instance.primaryFocus!.unfocus();
  //  }

  @override
  void onClose() {
    super.onClose();
  }
}
