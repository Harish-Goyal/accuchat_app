import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/storage_service.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/shares_pref_web.dart';

class VerifyOtpController extends GetxController{
  final formGlobalKey = GlobalKey<FormState>();
  var otpValue;
  var emailOrPhone;



  int secondsRemaining = 60;
  bool enableResend = false;
  bool otpSent = false;
  Timer? timer;
  TextEditingController otpFieldController = TextEditingController();
  bool isFill = false;
  hitAPIToVerifyOtp() async {
    FocusManager.instance.primaryFocus!.unfocus();
    var req = {
      "userInput": emailOrPhone,
      "otp": otpValue
    };

    Get.find<AuthApiServiceImpl>()
        .verifyOtpApiCall(dataBody: req)
        .then((value) async {
            storage.write(isFirstTimeChatKey, isFirstTimeChat);
            storage.write(isFirstTime, false);
            storage.write(LOCALKEY_token, value.data?.token);
            StorageService.saveToken(value.data?.token);

            await AppStorage().write(LOCALKEY_token, value.data?.token);

            Get.offAllNamed(AppRoutes.landing_r);
            update();
            toast(value.message??'');

      // openBottomSheet();
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      isFill = false;
      update();
    });
  }


 /* UserDataAPI userData = UserDataAPI();


 Future<void> hitAPIToGetUser() async {
    FocusManager.instance.primaryFocus!.unfocus();
    Get.find<AuthApiServiceImpl>()
        .getUserApiCall()
        .then((value) async {
      userData = value.data!;
            storage.write(user_mob, userData.phone??'');

    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }
*/

  hitAPIToResendOtp() async {
    FocusManager.instance.primaryFocus!.unfocus();
    customLoader.show();
    var req = {
      "userInput":  emailOrPhone,
    };
    enableResend = false;
    update();
    Get.find<AuthApiServiceImpl>()
        .signupApiCall(dataBody: req)
        .then((value) async {
      customLoader.hide();
      otpSent = true;
      Get.snackbar("Resent", value.message??'',
          backgroundColor: Colors.white, colorText: Colors.black);
    /*  Get.toNamed(AppRoutes.verifyOTPRoute,
          arguments: {
            'otpValue':otpValue,
            'emailOrPhone':emailOrPhone
          });*/
      update();

      // openBottomSheet();
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }


  @override
  void onInit() {
    getArguments();
    initTimer();
    super.onInit();
  }

  getArguments(){
    if(kIsWeb) {
      if (Get.arguments != null) {
        otpValue = Get.arguments['otpValue'];
        emailOrPhone = Get.arguments['emailOrPhone'];
      }
    }else{
      if (Get.parameters != null) {
        otpValue = Get.parameters['otpValue'];
        emailOrPhone = Get.parameters['emailOrPhone'];
      }
    }
  }


  initTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        secondsRemaining--;

        update();
      } else {
        enableResend = true;
        update();
      }
    });
  }

  @override
  void onClose() {
    timer?.cancel();
    super.dispose();
  }
}