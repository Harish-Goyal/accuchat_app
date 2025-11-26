
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/verify_otp_controller.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../../../Constants/colors.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/loading_indicator.dart';
import '../../../../../../utils/text_style.dart';

class VerifyOtpScreen extends GetView<VerifyOtpController> {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyOtpController>(
      builder: (controller) {
        return Scaffold(

          appBar: backAppBar(title: 'Verify OTP'),

          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              vGap(30),
                              Text(
                                'We have sent an OTP on your registered mobile number please enter below!',
                                style: BalooStyles.baloosemiBoldTextStyle(),
                                textAlign: TextAlign.center,
                              ).paddingSymmetric(horizontal: 15),
                              vGap(30),

                              PinFieldAutoFill(
                                codeLength: 6,
                                controller: controller.otpFieldController,
                                autoFocus: true,
                                decoration: UnderlineDecoration(
                                  textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                                  colorBuilder: FixedColorBuilder(appColorGreen),
                                  lineStrokeCap: StrokeCap.square,
                                ),
                                currentCode: controller.otpFieldController.text,
                                cursor: Cursor(color: appColorGreen,height: 20,width: 2,enabled: true),
                                onCodeSubmitted: (code) {},
                                onCodeChanged: (code) {
                                  if (code != null && code.length == 6) {
                                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                                    controller.otpFieldController.text = code;
                                    controller.isFill = true;
                                    controller.update();
                                    controller.hitAPIToVerifyOtp();
                                  }
                                },
                              ).paddingSymmetric(horizontal: 5, vertical: 35),

                              vGap(20),
                              controller.isFill
                                  ? IndicatorLoading()
                                  : GradientButton(
                                onTap: () {
                                  if (controller.formGlobalKey.currentState?.validate()??true) {
                                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                                    setState(() {
                                      controller.isFill = true;
                                    });
                                    controller.hitAPIToVerifyOtp();
                                  }
                                }
                                   ,
                                btnColor: controller.isFill ? AppTheme.appColor : Colors.grey.shade300,
                                name: 'Submit',
                              ).marginOnly(bottom: 80, left: 20, right: 20),

                              resendOTPView(context),
                            ],
                          ).marginSymmetric(horizontal: 20, vertical: 15),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          /*body: SafeArea(
            child: StatefulBuilder(builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    vGap(30),
                    Text(
                      'We have sent an OTP on your registered mobile number please enter below!',
                      style: BalooStyles.baloosemiBoldTextStyle(),
                      textAlign: TextAlign.center,
                    ).paddingSymmetric(horizontal: 15),
                    vGap(30),

                    PinFieldAutoFill(
                      codeLength: 6,
                      // cursor: Cursor(color: appColorGreen),

                      controller: controller.otpFieldController,
                      decoration: UnderlineDecoration(
                          textStyle: TextStyle(fontSize: 20, color: Colors.black),
                          colorBuilder: FixedColorBuilder(appColorGreen),
                          lineStrokeCap: StrokeCap.square),
                      currentCode:  controller.otpFieldController.text,
                      onCodeSubmitted: (code) {
                        // if (code != null && code.length == 6) {
                        //   otpVal = code;
                        //   isFill = true;
                        //   setState(() {});
                        //   verifyOTP();
                        // }
                      },
                      onCodeChanged: (code) {
                        if (code != null && code.length == 6) {
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                          controller.otpValue = code;
                          controller.isFill = true;
                          setState(() {});
                          controller.hitAPIToVerifyOtp();
                        }
                      },
                    ).paddingSymmetric(horizontal: 5, vertical: 35),

        *//*
                          OTPTextField(
                          length: 6,
                          controller: otpFieldController,
                          width: Get.width,
                          keyboardType: TextInputType.number,
                          fieldWidth: 45,
                          fieldStyle: FieldStyle.box,
                          style: const TextStyle(fontSize: 15),
                          onCompleted: (val) {

                      isFill = true;
                            otpVal = val;
                            setState(() {

                           });
                           verifyOTP();

                          },
                          onChanged: (otp){

                          },
                          otpFieldStyle: OtpFieldStyle(
                            backgroundColor: Colors.white,
                            enabledBorderColor: Colors.grey.shade300,
                            borderColor: Colors.grey.shade300,
                            focusBorderColor: AppTheme.appColor,
                          ),
                        ).paddingSymmetric(horizontal: 5,vertical: 35),
        *//*
                    // controller.resendOTPView(context, setState),
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
                    vGap(20),
                    controller.isFill
                        ? IndicatorLoading()
                        : GradientButton(
                      onTap:  controller.isFill
                          ? () {
                        if ( controller.formGlobalKey.currentState?.validate() ??
                            false) {
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          setState(() {
                            controller.isFill = true;
                          });
                          controller.hitAPIToVerifyOtp();
                        }
                      }
                          : () {},
                      btnColor:
                      controller.isFill ? AppTheme.appColor : Colors.grey.shade300,
                      name: 'Submit',
                    ).marginOnly(bottom: 80, left: 20, right: 20),
                    *//*  Stack(
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
                                          onTap:*//*
                    *//* controller.isFill
                                              ? () {
                                            if (formGlobalKey.currentState?.validate() ?? false) {
                                              controller.hitOtpAPI(otp:controller.otpVal );
                                            }
                                          }
                                              : *//*
                    *//*() {},
                                          btnColor: *//*
                    *//*controller.isFill
                                              ? appColor*//*
                    *//*
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
                        ),*//*

                    resendOTPView(context)



                  ],
                ).marginSymmetric(horizontal: 20, vertical: 15),
              );
            }),
          ),*/
        );
      }
    );
  }


  Widget resendOTPView(context) {
    return Column(
      children: [
        Obx(() {
          final canTap = controller.canResend.value && !controller.isSending.value;

          return TextButton(
            onPressed: canTap ? controller.hitApiToResendOtp : null,
            child: controller.isSending.value
                ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              controller.canResend.value
                  ? 'Resend OTP'
                  : 'Resend in ${controller.mmSs}',
            ),
          );
        }),        Obx(() => Text(
          controller.canResend.value
              ? 'Didn’t get the code? Tap “Resend OTP”.'
              : 'You can resend in ${controller.mmSs}',
          style: Theme.of(context).textTheme.bodySmall,
        ))
        // Text(controller.secondsRemaining.toString(),style: BalooStyles.baloosemiBoldTextStyle(color: Colors.red),)
      ],
    );
  }

  titleSubtileView(context) {
    return Text.rich(
      TextSpan(
          text: "Please Check your Phone. We've sent you the code at",
          style: BalooStyles.balooregularTextStyle(
              color: AppTheme.secondaryTextColor),
          children: [
            TextSpan(
              text: " ${controller.emailOrPhone}",
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
