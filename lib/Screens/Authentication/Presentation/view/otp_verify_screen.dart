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
   /*           OTPTextField(
                length: 4,
                controller: controller.otpFieldController,
                width: Get.width,
                keyboardType: TextInputType.number,
                fieldWidth: 55,
                fieldStyle: FieldStyle.box,
                style: const TextStyle(fontSize: 17),
                onCompleted: (val) {
                  controller.isFill = true;
                  controller.otpVal = val;
                  controller.update();
                  controller.hitApiToVerifyOtp(otp: val);
                },
                onChanged: (otp){

                },
                otpFieldStyle: OtpFieldStyle(
                  backgroundColor: Colors.white,
                  enabledBorderColor: Colors.grey.shade300,
                  borderColor: Colors.grey.shade300,
                  focusBorderColor: AppTheme.appColor,
                ),
              ).paddingSymmetric(horizontal: 10),*/
              resendOTPView(context),
              // GetBuilder<LoginController>(
              //   builder: (controller) {
              //     return Center(
              //       child: Text(
              //         '${controller.secondsRemaining}',
              //         style:  TextStyles(context).title(),
              //       ),
              //     );
              //   }
              // ),
              // vGap(20),
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
            /*  Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      height: Get.height,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                      ),
                      alignment: Alignment.topCenter,
                      child: Container(
                          height: Get.height * .53,
                          decoration:  BoxDecoration(
                              color: AppTheme.primaryColor,
                              // color: appColor,
                              // gradient: appBarGradient(),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(60, 0, 60, 70),
                              child: Image.asset(Localfiles.appIcon)))),
                  Positioned(
                    left: 15,
                    right: 15,
                    bottom: 30,
                    child: Container(
                        height:
                        Get.height < 650 ? Get.height * .44 : Get.height * .5,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.grey.shade500, blurRadius: 7)
                            ]),
                        padding: const EdgeInsets.all(0),
                        child: ListView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 30),
                            children: [
                              OTPTextField(
                                length: 6,
                                controller: controller.otpFieldController,
                                width: Get.width,
                                fieldWidth: 45,
                                fieldStyle: FieldStyle.box,
                                style: const TextStyle(fontSize: 17),
                                onCompleted: (val) {
                                  // controller.isFill = true;
                                  // controller.otpVal = val;
                                  // controller.update();
                                  // controller.hitOtpAPI(otp: val);
                                },
                                otpFieldStyle: OtpFieldStyle(
                                  backgroundColor: Colors.white,
                                  enabledBorderColor: Colors.grey.shade300,
                                  borderColor: Colors.grey.shade300,
                                  focusBorderColor: AppTheme.primaryColor,
                                ),
                              ),
                              resendOTPView(context),
                              Center(
                                child: Text(
                                  '${controller.secondsRemaining}',
                                  style:  TextStyles(context).title(),
                                ),
                              ),
                              vGap(20),
                              GradientButton(
                                onTap:*//* controller.isFill
                                    ? () {
                                  if (formGlobalKey.currentState?.validate() ?? false) {
                                    controller.hitOtpAPI(otp:controller.otpVal );
                                  }
                                }
                                    : *//*() {},
                                btnColor: *//*controller.isFill
                                    ? appColor*//*
                                Colors.grey.shade300,
                                name: 'Submit',
                              ).marginOnly(bottom: 20),
                            ])),
                  ),

                  Positioned(
                    top: Get.height*.3,

                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        vGap(20),
                        Text(
                          "Verification",
                          style: BalooStyles.balooregularTextStyle(),
                          textAlign: TextAlign.center,
                        ),  vGap(10),Text(
                          "Enter OTP, that is sent to your registered mobile number.",
                          style:TextStyles(context).description(),
                          textAlign: TextAlign.center,
                        ).paddingSymmetric(horizontal: 30),
                      ],
                    ),
                  ),
                  Positioned(top: 40, left: 15, child: backIcon()
                  )
                ],
              ),*/
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
