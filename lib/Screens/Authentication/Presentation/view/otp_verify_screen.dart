import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/gradient_button.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/text_style.dart';
import '../../../../Constants/themes.dart';
import '../controller/loginController.dart';


class BottomSheetWidget extends GetView<LoginController> {
  final formGlobalKey = GlobalKey<FormState>();
  final LoginController loginController = Get.put(LoginController());

  BottomSheetWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return  _bottomSheetWidget(context);

  }


  Widget _bottomSheetWidget(context) {
    return GetBuilder<LoginController>(
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            children: [

              vGap(20),
              titleSubtileView(context),
              vGap(20),
              resendOTPView(context),
              GradientButton(
                onTap: controller.isFill
                                    ? () {
                                  if (formGlobalKey.currentState?.validate() ?? false) {
                                    controller.hitApiToVerifyOtp(otp:controller.otpVal );
                                  }
                                }
                                    :() {},
                btnColor: controller.isFill
                                    ? AppTheme.appColor:
                Colors.grey.shade300,
                name: 'Submit',
              ).marginOnly(bottom: 20,left: 20,right: 20),
            ],
          ).marginSymmetric(horizontal: 20,vertical: 15),
        );
      }
    );
  }

  Widget resendOTPView(context) {
    return Text.rich(
      TextSpan(
          text: "Didn't receive the OTP? ".tr,
          style:
          BalooStyles.balooregularTextStyle(color: AppTheme.secondaryTextColor),
          children: [
            TextSpan(
              text: "Resend Now".tr,
              recognizer: new TapGestureRecognizer()
                ..onTap =
                controller.enableResend ? controller.resendCode : null,
              style: BalooStyles.balooregularTextStyle(color:  controller.enableResend ? AppTheme.appColor : Colors.grey.shade400),

            ),
          ]),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ).paddingSymmetric(vertical: 30, horizontal: 0);
  }

  titleSubtileView(context) {
    return Text.rich(
      TextSpan(
          text: "Please Check your Phone. We've sent you the code at",
          style: BalooStyles.balooregularTextStyle(color: AppTheme.secondaryTextColor),
          children: [
            TextSpan(
              text: " ${loginController.phoneController.text ?? ""}",
              style: BalooStyles.balooboldTitleTextStyle(),
            ),
          ]),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
