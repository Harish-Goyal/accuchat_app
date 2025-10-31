import 'dart:async';
import 'dart:io';

import 'package:AccuChat/Screens/Chat/api/session_alive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../Services/storage_service.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/shares_pref_web.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../api/apis.dart';
import '../../../../models/get_company_res_model.dart';

class VerifyOtpController extends GetxController{
  final formGlobalKey = GlobalKey<FormState>();
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
      "otp": otpFieldController.text
    };

    Get.find<AuthApiServiceImpl>()
        .verifyOtpApiCall(dataBody: req)
        .then((value) async {
      toast(value.message??'');

      Get.putAsync<Session>(() async {
        final s = Session(Get.find<AuthApiServiceImpl>(), Get.find<AppStorage>());

        CompanyData? selCompany;
        try {
          final svc = Get.find<CompanyService>();
          // OPTIONAL: if you add a `Future<void> ready` in CompanyService, await it here:
          // await svc.ready;
          selCompany = svc.selected; // may be null on clean install
        } catch (_) {}
        // company may not exist yet on fresh install:
        await s.initSafe(companyId: selCompany?.companyId??0); // <-- works with null/0
        return s;
      });
            StorageService.setFirstTimeTask(isFirstTimeChat);
            StorageService.saveToken(value.data?.token);
            StorageService.saveMobile(emailOrPhone);
            StorageService.setIsFirstTime(false);
            await AppStorage().write(LOCALKEY_token, value.data?.token);
            await APIs.getFirebaseMessagingToken();
            update();

      Get.offAllNamed(AppRoutes.landing_r);

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
      if (Get.parameters != null) {
        emailOrPhone = Get.parameters['emailOrPhone'];
      }

    }else{
      if (Get.arguments != null) {
        emailOrPhone = Get.arguments['emailOrPhone'];
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