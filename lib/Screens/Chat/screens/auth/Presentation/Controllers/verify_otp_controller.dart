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
import '../../../../../../Services/hive_boot.dart';
import '../../../../../../Services/storage_service.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/shares_pref_web.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../api/apis.dart';
import '../../../../helper/dialogs.dart';
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

      if (!Get.isRegistered<AppStorage>()) {
      await  Get.putAsync<AppStorage>(() async {
          await AppStorage().init(boxName: 'accu_chat');
          return AppStorage();
        }, permanent: true);
        await StorageService.init();
      }
       StorageService.setFirstTimeTask(isFirstTimeChat);
       StorageService.saveToken(value.data?.token);
       StorageService.saveMobile(emailOrPhone);
       StorageService.setIsFirstTime(false);
       await AppStorage().write(LOCALKEY_token, value.data?.token);
       Get.offAllNamed(AppRoutes.landing_r);
       await APIs.getFirebaseMessagingToken();

      // openBottomSheet();
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      isFill = false;
    }).then((v){});
  }

  final int cooldownSeconds = 60;

  // State
  final RxInt secondsLeft = 0.obs;
  final RxBool canResend = true.obs;
  final RxBool isSending = false.obs;


  /// Call this right after you send the first OTP
  void startCooldown([int? seconds]) {
    timer?.cancel();
    final total = seconds ?? cooldownSeconds;
    secondsLeft.value = total;
    canResend.value = false;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        t.cancel();
        secondsLeft.value = 0;
        canResend.value = true;
      } else {
        secondsLeft.value--;
      }
    });
  }



  Future<void> hitApiToResendOtp() async {
    if (!canResend.value || isSending.value) return;

    isSending.value = true;
    try {
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
        Dialogs.showSnackbar(Get.context!, value.message??'');

        update();
      }).onError((error, stackTrace) {
        customLoader.hide();
        errorDialog(error.toString());
        update();
      });

      startCooldown(); // restart 60s timer
    } catch (e) {
      Dialogs.showSnackbar(Get.context! ,e.toString(),
          );
    } finally {
      isSending.value = false;
    }
  }

  String get mmSs =>
      '00:${secondsLeft.value.toString().padLeft(2, '0')}';


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